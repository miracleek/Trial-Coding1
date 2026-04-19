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
const themeIcon   = document.getElementById('themeIcon');
const btnTheme    = document.getElementById('btnTheme');

// ── DOM — inside appScreen (grabbed after show) ────────────
let btnLogout, userAvatar, userName;
let form, inputName, inputAmount, inputCategory, inputDate, inputType;
let listEl, emptyState;
let totalIncomeEl, totalExpenseEl, totalBalanceEl, balanceCard;
let btnSubmit, btnExport;
let expenseCanvas, expenseEmpty, incomeCanvas, incomeEmpty;

function grabAppDom() {
  btnLogout      = document.getElementById('btnLogout');
  userAvatar     = document.getElementById('userAvatar');
  userName       = document.getElementById('userName');
  form           = document.getElementById('transactionForm');
  inputName      = document.getElementById('itemName');
  inputAmount    = document.getElementById('amount');
  inputCategory  = document.getElementById('category');
  inputDate      = document.getElementById('txDate');
  inputType      = document.getElementById('txType');
  listEl         = document.getElementById('transactionList');
  emptyState     = document.getElementById('emptyState');
  totalIncomeEl  = document.getElementById('totalIncome');
  totalExpenseEl = document.getElementById('totalExpense');
  totalBalanceEl = document.getElementById('totalBalance');
  balanceCard    = document.getElementById('balanceCard');
  btnSubmit      = document.getElementById('btnSubmit');
  btnExport      = document.getElementById('btnExport');
  expenseCanvas  = document.getElementById('spendingChart');
  expenseEmpty   = document.getElementById('chartEmpty');
  incomeCanvas   = document.getElementById('incomeChart');
  incomeEmpty    = document.getElementById('incomeChartEmpty');
}

// ── Theme (early, affects login page too) ─────────────────
applyTheme(localStorage.getItem(THEME_KEY) || 'light');
btnTheme.addEventListener('click', toggleTheme);

// ── Auth State ─────────────────────────────────────────────
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
  } catch (err) {
    console.error('Login error:', err.code, err.message);
    btnLogin.disabled = false;
    btnLogin.innerHTML = '<img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" alt="Google" width="20" height="20" /> Masuk dengan Google';
    if (err.code !== 'auth/popup-closed-by-user' && err.code !== 'auth/cancelled-popup-request') {
      alert('Login gagal: ' + err.message);
    }
  }
});

// ── Show / Hide Screens ────────────────────────────────────
function showLogin() {
  loginScreen.style.display = 'flex';
  appScreen.style.display   = 'none';
  if (unsubscribe) { unsubscribe(); unsubscribe = null; }
  transactions = [];
  btnLogin.disabled = false;
  btnLogin.innerHTML = '<img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" alt="Google" width="20" height="20" /> Masuk dengan Google';
}

function showApp(user) {
  loginScreen.style.display = 'none';
  appScreen.style.display   = 'block';

  // Grab DOM now that appScreen is visible
  grabAppDom();

  // User info
  userName.textContent = user.displayName || user.email;
  if (user.photoURL) {
    userAvatar.src = user.photoURL;
    userAvatar.style.display = 'block';
  } else {
    userAvatar.style.display = 'none';
  }

  // Logout
  btnLogout.addEventListener('click', async () => {
    if (unsubscribe) unsubscribe();
    await signOut(auth);
  });

  // Form events
  form.addEventListener('submit', handleSubmit);
  btnExport.addEventListener('click', handleExport);

  // Init
  inputDate.value = todayISO();
  populateCategories('Pengeluaran');
  bindTypeToggle();
  bindFilterTabs();
  bindAmountMask();
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
    console.error('Firestore error:', err);
  });
}

// ── Theme ──────────────────────────────────────────────────
function applyTheme(theme) {
  htmlEl.setAttribute('data-theme', theme);
  if (themeIcon) themeIcon.textContent = theme === 'dark' ? '☀️' : '🌙';
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
      inputType.value = activeType;
      populateCategories(activeType);
      btnSubmit.classList.toggle('income-mode', activeType === 'Pendapatan');
      btnSubmit.textContent = activeType === 'Pendapatan' ? '+ Tambah Pendapatan' : '+ Tambah Pengeluaran';
    });
  });
}

function populateCategories(type) {
  const cats = type === 'Pendapatan' ? INCOME_CATEGORIES : EXPENSE_CATEGORIES;
  inputCategory.innerHTML = '<option value="">-- Pilih Kategori --</option>';
  Object.entries(cats).forEach(([name, { icon }]) => {
    const opt = document.createElement('option');
    opt.value = name;
    opt.textContent = `${icon} ${name}`;
    inputCategory.appendChild(opt);
  });
  inputCategory.classList.remove('invalid');
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

// ── Handlers ───────────────────────────────────────────────
async function handleSubmit(e) {
  e.preventDefault();
  if (!validateForm() || !currentUser) return;

  const tx = {
    type:      activeType,
    name:      inputName.value.trim(),
    amount:    parseInt(rawAmount, 10),
    category:  inputCategory.value,
    date:      inputDate.value,
    createdAt: Date.now(),
  };

  try {
    btnSubmit.disabled = true;
    btnSubmit.textContent = 'Menyimpan...';
    await addDoc(collection(db, 'users', currentUser.uid, 'transactions'), tx);
    form.reset();
    rawAmount = '';
    inputDate.value = todayISO();
    populateCategories(activeType);
  } catch (err) {
    console.error('Gagal menyimpan:', err);
    alert('Gagal menyimpan transaksi. Cek koneksi internet.');
  } finally {
    btnSubmit.disabled = false;
    btnSubmit.textContent = activeType === 'Pendapatan' ? '+ Tambah Pendapatan' : '+ Tambah Pengeluaran';
  }
}

async function handleDelete(id) {
  if (!currentUser) return;
  try {
    await deleteDoc(doc(db, 'users', currentUser.uid, 'transactions', id));
  } catch (err) {
    console.error('Gagal menghapus:', err);
    alert('Gagal menghapus transaksi. Cek koneksi internet.');
  }
}

// ── Validation ─────────────────────────────────────────────
function validateForm() {
  let valid = true;

  const fields = [
    { el: inputName,     errId: 'err-itemName', msg: 'Nama item wajib diisi.' },
    { el: inputCategory, errId: 'err-category', msg: 'Pilih kategori terlebih dahulu.' },
    { el: inputDate,     errId: 'err-txDate',   msg: 'Tanggal wajib diisi.' },
  ];

  fields.forEach(({ el, errId, msg }) => {
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

  totalIncomeEl.textContent  = formatRupiah(income);
  totalExpenseEl.textContent = formatRupiah(expense);
  totalBalanceEl.textContent = (balance < 0 ? '- ' : '') + formatRupiah(Math.abs(balance));
  balanceCard.classList.toggle('negative', balance < 0);
}

function renderList() {
  Array.from(listEl.querySelectorAll('.transaction-item')).forEach(el => el.remove());

  const filtered = (activeFilter === 'Semua'
    ? transactions
    : transactions.filter(tx => tx.type === activeFilter)
  ).slice().sort((a, b) => a.date.localeCompare(b.date));

  btnExport.disabled = transactions.length === 0;

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
    canvas:  expenseCanvas,
    emptyEl: expenseEmpty,
    ref:     'expense',
  });
  renderPieChart({
    txList:  transactions.filter(tx => tx.type === 'Pendapatan'),
    cats:    INCOME_CATEGORIES,
    canvas:  incomeCanvas,
    emptyEl: incomeEmpty,
    ref:     'income',
  });
}

function renderPieChart({ txList, cats, canvas, emptyEl, ref }) {
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
function formatRupiah(amount) {
  return 'Rp ' + amount.toLocaleString('id-ID');
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
