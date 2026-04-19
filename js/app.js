/* ===========================
   Finance Tracker — app.js
   Vanilla JS | Firebase Auth + Firestore
=========================== */

import {
  db, auth, provider,
  collection, addDoc, deleteDoc, doc,
  onSnapshot, query, orderBy,
  signInWithPopup, signOut, onAuthStateChanged,
} from "./firebase.js";

// ── Constants ──────────────────────────────────────────────
const THEME_KEY = 'finance_tracker_theme';

const EXPENSE_CATEGORIES = {
  Makan:        { icon: '🍽️', color: '#f97316' },
  Transportasi: { icon: '🚗', color: '#3b82f6' },
  Transfer:     { icon: '💸', color: '#8b5cf6' },
};

const INCOME_CATEGORIES = {
  Gaji:      { icon: '💼', color: '#10b981' },
  Freelance: { icon: '💻', color: '#06b6d4' },
  Investasi: { icon: '📈', color: '#f59e0b' },
  Lainnya:   { icon: '➕', color: '#6b7280' },
};

// ── State ──────────────────────────────────────────────────
let transactions = [];
let activeType   = 'Pengeluaran';
let activeFilter = 'Semua';
let rawAmount    = '';
let expenseChart = null;
let incomeChart  = null;
let currentUser  = null;
let unsubscribe  = null;

// ── DOM — always present ───────────────────────────────────
const htmlEl      = document.documentElement;
const loginScreen = document.getElementById('loginScreen');
const appScreen   = document.getElementById('appScreen');
const btnLogin    = document.getElementById('btnLogin');

// Theme buttons (one on login, one on app)
const btnThemeLogin = document.getElementById('btnTheme');
const themeIconLogin = document.getElementById('themeIcon');
const btnThemeApp   = document.getElementById('btnThemeApp');
const themeIconApp  = document.getElementById('themeIconApp');

// ── Theme (runs immediately, affects both screens) ─────────
applyTheme(localStorage.getItem(THEME_KEY) || 'light');
btnThemeLogin.addEventListener('click', toggleTheme);
btnThemeApp.addEventListener('click', toggleTheme);

// ── Auth State Listener ────────────────────────────────────
onAuthStateChanged(auth, (user) => {
  if (user) {
    currentUser = user;
    showApp(user);
  } else {
    currentUser = null;
    showLogin();
  }
});

// ── Login ──────────────────────────────────────────────────
btnLogin.addEventListener('click', async () => {
  try {
    btnLogin.disabled = true;
    btnLogin.textContent = 'Menghubungkan...';
    await signInWithPopup(auth, provider);
    // onAuthStateChanged handles the rest
  } catch (err) {
    console.error('Login error:', err.code, err.message);
    btnLogin.disabled = false;
    btnLogin.innerHTML = `
      <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" alt="Google" width="20" height="20" />
      Masuk dengan Google`;
    if (err.code !== 'auth/popup-closed-by-user' && err.code !== 'auth/cancelled-popup-request') {
      alert('Login gagal. Coba lagi.');
    }
  }
});

// ── Show Login ─────────────────────────────────────────────
function showLogin() {
  loginScreen.style.display = 'flex';
  appScreen.style.display   = 'none';
  if (unsubscribe) { unsubscribe(); unsubscribe = null; }
  transactions = [];
  // Reset charts
  if (expenseChart) { expenseChart.destroy(); expenseChart = null; }
  if (incomeChart)  { incomeChart.destroy();  incomeChart  = null; }
  // Reset login button
  btnLogin.disabled = false;
  btnLogin.innerHTML = `
    <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" alt="Google" width="20" height="20" />
    Masuk dengan Google`;
}

// ── Show App ───────────────────────────────────────────────
function showApp(user) {
  loginScreen.style.display = 'none';
  appScreen.style.display   = 'block';

  // User info
  document.getElementById('userName').textContent = user.displayName || user.email;
  const avatarEl = document.getElementById('userAvatar');
  if (user.photoURL) {
    avatarEl.src = user.photoURL;
    avatarEl.style.display = 'block';
  } else {
    avatarEl.style.display = 'none';
  }

  // Logout
  document.getElementById('btnLogout').addEventListener('click', async () => {
    if (unsubscribe) { unsubscribe(); unsubscribe = null; }
    await signOut(auth);
  });

  // Form & export
  document.getElementById('transactionForm').addEventListener('submit', handleSubmit);
  document.getElementById('btnExport').addEventListener('click', handleExport);

  // Init form
  document.getElementById('txDate').value = todayISO();
  populateCategories('Pengeluaran');
  bindTypeToggle();
  bindFilterTabs();
  bindAmountMask();

  // Start listening to Firestore
  listenToFirestore(user.uid);
}

// ── Firestore Realtime Listener ────────────────────────────
function listenToFirestore(uid) {
  if (unsubscribe) unsubscribe();
  const q = query(
    collection(db, 'users', uid, 'transactions'),
    orderBy('date', 'asc')
  );
  unsubscribe = onSnapshot(q, (snapshot) => {
    transactions = snapshot.docs.map(d => ({ id: d.id, ...d.data() }));
    render();
  }, (err) => {
    console.error('Firestore listener error:', err);
  });
}

// ── Theme ──────────────────────────────────────────────────
function applyTheme(theme) {
  htmlEl.setAttribute('data-theme', theme);
  const icon = theme === 'dark' ? '☀️' : '🌙';
  if (themeIconLogin) themeIconLogin.textContent = icon;
  if (themeIconApp)   themeIconApp.textContent   = icon;
  localStorage.setItem(THEME_KEY, theme);

  Chart.defaults.color = theme === 'dark' ? '#94a3b8' : '#64748b';

  if (expenseChart) { expenseChart.destroy(); expenseChart = null; }
  if (incomeChart)  { incomeChart.destroy();  incomeChart  = null; }
  if (currentUser) renderCharts();
}

function toggleTheme() {
  applyTheme(htmlEl.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
}

// ── Type Toggle ────────────────────────────────────────────
function bindTypeToggle() {
  document.querySelectorAll('.type-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.type-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      activeType = btn.dataset.type;
      document.getElementById('txType').value = activeType;
      populateCategories(activeType);
      const btnSubmit = document.getElementById('btnSubmit');
      btnSubmit.classList.toggle('income-mode', activeType === 'Pendapatan');
      btnSubmit.textContent = activeType === 'Pendapatan' ? '+ Tambah Pendapatan' : '+ Tambah Pengeluaran';
    });
  });
}

function populateCategories(type) {
  const cats = type === 'Pendapatan' ? INCOME_CATEGORIES : EXPENSE_CATEGORIES;
  const sel  = document.getElementById('category');
  sel.innerHTML = '<option value="">-- Pilih Kategori --</option>';
  Object.entries(cats).forEach(([name, { icon }]) => {
    const opt = document.createElement('option');
    opt.value = name;
    opt.textContent = `${icon} ${name}`;
    sel.appendChild(opt);
  });
  sel.classList.remove('invalid');
  document.getElementById('err-category').textContent = '';
}

// ── Filter Tabs ────────────────────────────────────────────
function bindFilterTabs() {
  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      activeFilter = btn.dataset.filter;
      renderList();
    });
  });
}

// ── Amount Masking ─────────────────────────────────────────
function bindAmountMask() {
  const inputAmount = document.getElementById('amount');
  inputAmount.addEventListener('input', () => {
    const digits = inputAmount.value.replace(/\D/g, '');
    rawAmount = digits;
    inputAmount.value = digits === '' ? '' : parseInt(digits, 10).toLocaleString('id-ID');
    inputAmount.closest('.amount-wrapper').classList.remove('invalid');
    document.getElementById('err-amount').textContent = '';
  });
  inputAmount.addEventListener('keydown', (e) => {
    const allowed = ['Backspace','Delete','ArrowLeft','ArrowRight','ArrowUp','ArrowDown','Tab','Home','End'];
    if (!allowed.includes(e.key) && !/^\d$/.test(e.key)) e.preventDefault();
  });
}

// ── Submit Handler ─────────────────────────────────────────
async function handleSubmit(e) {
  e.preventDefault();
  if (!validateForm() || !currentUser) return;

  const btnSubmit = document.getElementById('btnSubmit');
  const tx = {
    type:      activeType,
    name:      document.getElementById('itemName').value.trim(),
    amount:    parseInt(rawAmount, 10),
    category:  document.getElementById('category').value,
    date:      document.getElementById('txDate').value,
    createdAt: Date.now(),
  };

  try {
    btnSubmit.disabled = true;
    btnSubmit.textContent = 'Menyimpan...';
    await addDoc(collection(db, 'users', currentUser.uid, 'transactions'), tx);
    e.target.reset();
    rawAmount = '';
    document.getElementById('txDate').value = todayISO();
    populateCategories(activeType);
  } catch (err) {
    console.error('Gagal menyimpan:', err);
    alert('Gagal menyimpan transaksi. Cek koneksi internet.');
  } finally {
    btnSubmit.disabled = false;
    btnSubmit.textContent = activeType === 'Pendapatan' ? '+ Tambah Pendapatan' : '+ Tambah Pengeluaran';
  }
}

// ── Delete Handler ─────────────────────────────────────────
async function handleDelete(id) {
  if (!currentUser) return;
  try {
    await deleteDoc(doc(db, 'users', currentUser.uid, 'transactions', id));
  } catch (err) {
    console.error('Gagal menghapus:', err);
    alert('Gagal menghapus transaksi.');
  }
}

// ── Validation ─────────────────────────────────────────────
function validateForm() {
  let valid = true;

  const fields = [
    { id: 'itemName',  errId: 'err-itemName', msg: 'Nama item wajib diisi.' },
    { id: 'category',  errId: 'err-category', msg: 'Pilih kategori terlebih dahulu.' },
    { id: 'txDate',    errId: 'err-txDate',   msg: 'Tanggal wajib diisi.' },
  ];

  fields.forEach(({ id, errId, msg }) => {
    const el    = document.getElementById(id);
    const errEl = document.getElementById(errId);
    if (!el.value.trim()) {
      el.classList.add('invalid');
      errEl.textContent = msg;
      valid = false;
    } else {
      el.classList.remove('invalid');
      errEl.textContent = '';
    }
  });

  const inputAmount   = document.getElementById('amount');
  const amountWrapper = inputAmount.closest('.amount-wrapper');
  const amountErrEl   = document.getElementById('err-amount');
  const amountVal     = parseInt(rawAmount, 10);
  if (!rawAmount || isNaN(amountVal) || amountVal <= 0) {
    amountWrapper.classList.add('invalid');
    amountErrEl.textContent = 'Jumlah wajib diisi dan harus lebih dari 0.';
    valid = false;
  } else {
    amountWrapper.classList.remove('invalid');
    amountErrEl.textContent = '';
  }

  return valid;
}

// ── Render ─────────────────────────────────────────────────
function render() {
  renderSummary();
  renderList();
  renderCharts();
}

function renderSummary() {
  const income  = transactions.filter(tx => tx.type === 'Pendapatan').reduce((s, tx) => s + tx.amount, 0);
  const expense = transactions.filter(tx => tx.type === 'Pengeluaran').reduce((s, tx) => s + tx.amount, 0);
  const balance = income - expense;

  document.getElementById('totalIncome').textContent  = formatRupiah(income);
  document.getElementById('totalExpense').textContent = formatRupiah(expense);
  document.getElementById('totalBalance').textContent = (balance < 0 ? '- ' : '') + formatRupiah(Math.abs(balance));
  document.getElementById('balanceCard').classList.toggle('negative', balance < 0);
}

function renderList() {
  const listEl = document.getElementById('transactionList');
  Array.from(listEl.querySelectorAll('.transaction-item')).forEach(el => el.remove());

  const filtered = (activeFilter === 'Semua'
    ? transactions
    : transactions.filter(tx => tx.type === activeFilter)
  ).slice().sort((a, b) => a.date.localeCompare(b.date));

  document.getElementById('btnExport').disabled = transactions.length === 0;

  const emptyState = document.getElementById('emptyState');
  if (filtered.length === 0) {
    emptyState.style.display = 'block';
    return;
  }
  emptyState.style.display = 'none';

  filtered.forEach(tx => {
    const cats    = tx.type === 'Pendapatan' ? INCOME_CATEGORIES : EXPENSE_CATEGORIES;
    const catMeta = cats[tx.category] || { icon: '•' };
    const isIncome = tx.type === 'Pendapatan';

    const item = document.createElement('div');
    item.className = `transaction-item cat-${tx.category}`;
    item.dataset.id = tx.id;
    item.innerHTML = `
      <div class="tx-info">
        <span class="tx-name">${escapeHTML(tx.name)}</span>
        <div class="tx-meta">
          <span class="tx-type-pill ${tx.type}">${isIncome ? '📥' : '📤'} ${tx.type}</span>
          <span class="tx-badge badge-${tx.category}">${catMeta.icon} ${tx.category}</span>
          <span>${formatDate(tx.date)}</span>
        </div>
      </div>
      <span class="tx-amount ${isIncome ? 'income' : 'expense'}">
        ${isIncome ? '+' : '-'} ${formatRupiah(tx.amount)}
      </span>
      <button class="btn-delete" title="Hapus" aria-label="Hapus ${escapeHTML(tx.name)}">🗑️</button>
    `;
    item.querySelector('.btn-delete').addEventListener('click', () => handleDelete(tx.id));
    listEl.appendChild(item);
  });
}

function renderCharts() {
  renderPieChart({
    txList:  transactions.filter(tx => tx.type === 'Pengeluaran'),
    cats:    EXPENSE_CATEGORIES,
    canvasId: 'spendingChart',
    emptyId:  'chartEmpty',
    ref:     'expense',
  });
  renderPieChart({
    txList:  transactions.filter(tx => tx.type === 'Pendapatan'),
    cats:    INCOME_CATEGORIES,
    canvasId: 'incomeChart',
    emptyId:  'incomeChartEmpty',
    ref:     'income',
  });
}

function renderPieChart({ txList, cats, canvasId, emptyId, ref }) {
  const canvas  = document.getElementById(canvasId);
  const emptyEl = document.getElementById(emptyId);

  const totals = {};
  txList.forEach(tx => { totals[tx.category] = (totals[tx.category] || 0) + tx.amount; });

  const labels  = Object.keys(totals);
  const data    = Object.values(totals);
  const colors  = labels.map(l => cats[l]?.color || '#94a3b8');
  const hasData = labels.length > 0;

  canvas.style.display  = hasData ? 'block' : 'none';
  emptyEl.style.display = hasData ? 'none'  : 'block';

  const existing = ref === 'expense' ? expenseChart : incomeChart;

  if (!hasData) {
    if (existing) existing.destroy();
    if (ref === 'expense') expenseChart = null;
    else incomeChart = null;
    return;
  }

  if (existing) {
    existing.data.labels = labels;
    existing.data.datasets[0].data = data;
    existing.data.datasets[0].backgroundColor = colors;
    existing.update();
    return;
  }

  const instance = new Chart(canvas, {
    type: 'pie',
    data: {
      labels,
      datasets: [{ data, backgroundColor: colors, borderWidth: 2, borderColor: 'transparent', hoverOffset: 8 }],
    },
    options: {
      responsive: true,
      plugins: {
        legend: {
          position: 'bottom',
          labels: { padding: 14, font: { size: 12 }, usePointStyle: true, pointStyleWidth: 10 },
        },
        tooltip: {
          callbacks: {
            label(ctx) {
              const val   = ctx.parsed;
              const total = ctx.dataset.data.reduce((a, b) => a + b, 0);
              return ` ${formatRupiah(val)} (${((val / total) * 100).toFixed(1)}%)`;
            },
          },
        },
      },
    },
  });

  if (ref === 'expense') expenseChart = instance;
  else incomeChart = instance;
}

// ── Export Excel ───────────────────────────────────────────
function handleExport() {
  if (transactions.length === 0) return;

  const sorted = transactions.slice().sort((a, b) => a.date.localeCompare(b.date));
  const header = ['Tanggal', 'Keterangan / Nama Item', 'Tipe Transaksi', 'Kategori', 'Jumlah (Rp)'];
  const rows   = sorted.map(tx => [formatDate(tx.date), tx.name, tx.type, tx.category, tx.amount]);

  const ws = XLSX.utils.aoa_to_sheet([header, ...rows]);
  ws['!cols'] = [{ wch: 14 }, { wch: 30 }, { wch: 16 }, { wch: 16 }, { wch: 18 }];

  header.forEach((_, c) => {
    const addr = XLSX.utils.encode_cell({ r: 0, c });
    if (ws[addr]) ws[addr].s = { font: { bold: true } };
  });
  for (let r = 1; r <= rows.length; r++) {
    const addr = XLSX.utils.encode_cell({ r, c: 4 });
    if (ws[addr]) { ws[addr].t = 'n'; ws[addr].z = '#,##0'; }
  }

  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Transaksi');
  XLSX.writeFile(wb, `finance-tracker-${todayISO()}.xlsx`);
}

// ── Helpers ────────────────────────────────────────────────
function formatRupiah(n) {
  return 'Rp ' + n.toLocaleString('id-ID');
}

function formatDate(iso) {
  if (!iso) return '';
  const [y, m, d] = iso.split('-');
  return `${d}/${m}/${y}`;
}

function todayISO() {
  return new Date().toISOString().split('T')[0];
}

function escapeHTML(str) {
  return str
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}
