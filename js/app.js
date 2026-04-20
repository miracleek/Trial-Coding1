/* ===========================
   Finance Tracker — app.js
   Vanilla JS | Firebase Auth + Firestore
=========================== */

import {
  db, auth, provider,
  collection, addDoc, deleteDoc, doc,
  onSnapshot, query, orderBy,
  signInWithPopup, signOut, onAuthStateChanged,
  setDoc, getDoc, getDocs, updateDoc,
} from "./firebase.js";

// ── Constants ──────────────────────────────────────────────
const THEME_KEY  = 'finance_tracker_theme';
const ADMIN_EMAIL = 'eduworkrin@gmail.com';

// Default categories seeded on first login
const DEFAULT_EXPENSE_CATS = [
  { name: 'Makan',        icon: 'food',   color: '#f97316', type: 'Pengeluaran' },
  { name: 'Transportasi', icon: 'car',    color: '#3b82f6', type: 'Pengeluaran' },
  { name: 'Transfer',     icon: 'money',  color: '#8b5cf6', type: 'Pengeluaran' },
];
const DEFAULT_INCOME_CATS = [
  { name: 'Gaji',      icon: 'work',   color: '#10b981', type: 'Pendapatan' },
  { name: 'Freelance', icon: 'laptop', color: '#06b6d4', type: 'Pendapatan' },
  { name: 'Investasi', icon: 'chart',  color: '#f59e0b', type: 'Pendapatan' },
  { name: 'Lainnya',   icon: 'plus',   color: '#6b7280', type: 'Pendapatan' },
];

// Icon map (emoji) — used when rendering
const ICON_MAP = {
  food:'🍽️', car:'🚗', money:'💸', work:'💼',
  laptop:'💻', chart:'📈', plus:'➕', star:'⭐',
  home:'🏠', health:'💊', shop:'🛍️', fun:'🎮',
  edu:'📚', gift:'🎁', pet:'🐾', travel:'✈️',
};

// ── State ──────────────────────────────────────────────────
let transactions    = [];
let categories      = [];
let currentUser     = null;
let currentUserRole = 'user';
let activePage      = 'dashboard';
let reportFilter    = 'Semua';
let reportMonth     = '';
let catFilter       = 'Pengeluaran';
let rawIncomeAmt    = '';
let rawExpenseAmt   = '';
let expenseChart    = null;
let incomeChart     = null;
let unsubTx         = null;
let unsubCats       = null;
let editingCatId    = null;


// ── DOM ────────────────────────────────────────────────────
const htmlEl         = document.documentElement;
const loginScreen    = document.getElementById('loginScreen');
const appScreen      = document.getElementById('appScreen');
const btnLogin       = document.getElementById('btnLogin');
const btnThemeLogin  = document.getElementById('btnTheme');
const themeIconLogin = document.getElementById('themeIcon');
const btnThemeApp    = document.getElementById('btnThemeApp');
const themeIconApp   = document.getElementById('themeIconApp');
const sidebar        = document.getElementById('sidebar');
const sidebarOverlay = document.getElementById('sidebarOverlay');

// ── Theme ──────────────────────────────────────────────────
applyTheme(localStorage.getItem(THEME_KEY) || 'light');
btnThemeLogin.addEventListener('click', toggleTheme);
btnThemeApp.addEventListener('click', toggleTheme);

function applyTheme(theme) {
  htmlEl.setAttribute('data-theme', theme);
  const icon = theme === 'dark' ? '☀️' : '🌙';
  if (themeIconLogin) themeIconLogin.textContent = icon;
  if (themeIconApp)   themeIconApp.textContent   = icon;
  localStorage.setItem(THEME_KEY, theme);
  Chart.defaults.color = theme === 'dark' ? '#94a3b8' : '#64748b';
  if (expenseChart) { expenseChart.destroy(); expenseChart = null; }
  if (incomeChart)  { incomeChart.destroy();  incomeChart  = null; }
  if (currentUser && activePage === 'dashboard') renderCharts();
}

function toggleTheme() {
  applyTheme(htmlEl.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
}

// ── Sidebar ────────────────────────────────────────────────
document.getElementById('btnHamburger').addEventListener('click', () => {
  sidebar.classList.add('open');
  sidebarOverlay.classList.add('visible');
});
document.getElementById('sidebarClose').addEventListener('click', closeSidebar);
sidebarOverlay.addEventListener('click', closeSidebar);

function closeSidebar() {
  sidebar.classList.remove('open');
  sidebarOverlay.classList.remove('visible');
}

document.querySelectorAll('.nav-item').forEach(btn => {
  btn.addEventListener('click', () => {
    navigateTo(btn.dataset.page);
    closeSidebar();
  });
});

function navigateTo(page) {
  activePage = page;
  document.querySelectorAll('.nav-item').forEach(b =>
    b.classList.toggle('active', b.dataset.page === page)
  );
  document.querySelectorAll('.page').forEach(p =>
    p.classList.toggle('active', p.id === 'page-' + page)
  );
  if (page === 'dashboard') renderCharts();
  if (page === 'report')    renderReport();
  if (page === 'users')     renderUsers();
  if (page === 'categories') renderCategoryList();
}

// ── Auth ───────────────────────────────────────────────────
onAuthStateChanged(auth, async (user) => {
  if (user) {
    currentUser = user;
    await registerOrUpdateUser(user);
    const role = await getUserRole(user.uid);
    currentUserRole = role;
    showApp(user);
  } else {
    currentUser = null;
    currentUserRole = 'user';
    showLogin();
  }
});

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
      alert('Login gagal. Coba lagi.');
    }
  }
});

// ── Register / update user in Firestore ────────────────────
async function registerOrUpdateUser(user) {
  try {
    const ref  = doc(db, 'appUsers', user.uid);
    const snap = await getDoc(ref);
    const now  = Date.now();
    const isAdmin = user.email === ADMIN_EMAIL;
    if (!snap.exists()) {
      await setDoc(ref, {
        uid:         user.uid,
        displayName: user.displayName || '',
        email:       user.email || '',
        photoURL:    user.photoURL || '',
        role:        isAdmin ? 'admin' : 'user',
        status:      'active',
        firstLogin:  now,
        lastLogin:   now,
      });
    } else {
      const updates = { lastLogin: now, displayName: user.displayName || '', photoURL: user.photoURL || '' };
      if (isAdmin && snap.data().role !== 'admin') updates.role = 'admin';
      await updateDoc(ref, updates);
    }
  } catch (err) { console.error('registerOrUpdateUser:', err); }
}

async function getUserRole(uid) {
  try {
    const snap = await getDoc(doc(db, 'appUsers', uid));
    return snap.exists() ? (snap.data().role || 'user') : 'user';
  } catch { return 'user'; }
}


// ── Show Login ─────────────────────────────────────────────
function showLogin() {
  loginScreen.style.display = 'flex';
  appScreen.style.display   = 'none';
  if (unsubTx)   { unsubTx();   unsubTx   = null; }
  if (unsubCats) { unsubCats(); unsubCats = null; }
  transactions = []; categories = [];
  if (expenseChart) { expenseChart.destroy(); expenseChart = null; }
  if (incomeChart)  { incomeChart.destroy();  incomeChart  = null; }
  btnLogin.disabled = false;
  btnLogin.innerHTML = '<img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" alt="Google" width="20" height="20" /> Masuk dengan Google';
}

// ── Show App ───────────────────────────────────────────────
function showApp(user) {
  loginScreen.style.display = 'none';
  appScreen.style.display   = 'block';

  document.getElementById('userName').textContent = user.displayName || user.email;
  document.getElementById('userRoleBadge').textContent = currentUserRole === 'admin' ? '👑 Admin' : '👤 User';
  const avatarEl = document.getElementById('userAvatar');
  if (user.photoURL) { avatarEl.src = user.photoURL; avatarEl.style.display = 'block'; }
  else { avatarEl.style.display = 'none'; }

  // Show/hide admin-only nav items
  document.querySelectorAll('.admin-only').forEach(el => {
    el.style.display = currentUserRole === 'admin' ? '' : 'none';
  });

  document.getElementById('btnLogout').addEventListener('click', async () => {
    if (unsubTx)   { unsubTx();   unsubTx   = null; }
    if (unsubCats) { unsubCats(); unsubCats = null; }
    await signOut(auth);
  });

  document.getElementById('incomeDate').value  = '';
  document.getElementById('expenseDate').value = '';

  document.getElementById('incomeForm').addEventListener('submit',   handleIncomeSubmit);
  document.getElementById('expenseForm').addEventListener('submit',  handleExpenseSubmit);
  document.getElementById('categoryForm').addEventListener('submit', handleCategorySubmit);

  bindAmountMask('incomeAmount',  () => rawIncomeAmt,  v => { rawIncomeAmt  = v; });
  bindAmountMask('expenseAmount', () => rawExpenseAmt, v => { rawExpenseAmt = v; });

  // Report filter tabs
  document.querySelectorAll('[data-filter]').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('[data-filter]').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      reportFilter = btn.dataset.filter;
      renderReport();
    });
  });
  document.getElementById('reportMonth').addEventListener('change', e => {
    reportMonth = e.target.value;
    renderReport();
  });
  document.getElementById('btnExport').addEventListener('click', handleExport);

  // Category filter tabs
  document.querySelectorAll('[data-cat-filter]').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('[data-cat-filter]').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      catFilter = btn.dataset.catFilter;
      renderCategoryList();
    });
  });

  // Dashboard period filter
  document.getElementById('dashPeriod').addEventListener('change', () => renderCharts());

  // User search
  document.getElementById('userSearch').addEventListener('input', renderUsers);

  listenCategories(user.uid);
  listenTransactions(user.uid);
}

// ── Firestore Listeners ────────────────────────────────────
function listenTransactions(uid) {
  if (unsubTx) unsubTx();
  const q = query(collection(db, 'users', uid, 'transactions'), orderBy('date', 'asc'));
  unsubTx = onSnapshot(q, snap => {
    transactions = snap.docs.map(d => ({ id: d.id, ...d.data() }));
    renderSummary();
    renderIncomeList();
    renderExpenseList();
    if (activePage === 'dashboard') renderCharts();
    if (activePage === 'report')    renderReport();
  }, err => console.error('tx listener:', err));
}

function listenCategories(uid) {
  if (unsubCats) unsubCats();
  const q = query(collection(db, 'users', uid, 'categories'), orderBy('name', 'asc'));
  unsubCats = onSnapshot(q, async snap => {
    categories = snap.docs.map(d => ({ id: d.id, ...d.data() }));
    // Seed defaults if empty
    if (categories.length === 0) {
      await seedDefaultCategories(uid);
      return;
    }
    populateCategorySelect('incomeCategory',  'Pendapatan');
    populateCategorySelect('expenseCategory', 'Pengeluaran');
    if (activePage === 'categories') renderCategoryList();
  }, err => console.error('cats listener:', err));
}

async function seedDefaultCategories(uid) {
  const all = [...DEFAULT_EXPENSE_CATS, ...DEFAULT_INCOME_CATS];
  for (const cat of all) {
    await addDoc(collection(db, 'users', uid, 'categories'), cat);
  }
}


// ── Summary ────────────────────────────────────────────────
function renderSummary() {
  const income  = transactions.filter(t => t.type === 'Pendapatan').reduce((s, t) => s + t.amount, 0);
  const expense = transactions.filter(t => t.type === 'Pengeluaran').reduce((s, t) => s + t.amount, 0);
  const balance = income - expense;
  document.getElementById('totalIncome').textContent  = formatRupiah(income);
  document.getElementById('totalExpense').textContent = formatRupiah(expense);
  document.getElementById('totalBalance').textContent = (balance < 0 ? '- ' : '') + formatRupiah(Math.abs(balance));
  document.getElementById('balanceCard').classList.toggle('negative', balance < 0);
}

// ── Category Selects ───────────────────────────────────────
function populateCategorySelect(selectId, type) {
  const input    = document.getElementById(selectId);
  const datalist = document.getElementById(selectId + 'List');
  if (!datalist) return;
  const prev = input.value;
  datalist.innerHTML = '';
  categories.filter(c => c.type === type).forEach(c => {
    const opt = document.createElement('option');
    opt.value = (ICON_MAP[c.icon] || c.icon || '•') + ' ' + c.name;
    datalist.appendChild(opt);
  });
  if (prev) input.value = prev;
}

function getCatMeta(name) {
  return categories.find(c => c.name === name) || { icon: 'plus', color: '#94a3b8' };
}

// ── Income List ────────────────────────────────────────────
function renderIncomeList() {
  const el = document.getElementById('incomeList');
  const list = transactions.filter(t => t.type === 'Pendapatan').slice().sort((a,b) => b.date.localeCompare(a.date));
  if (list.length === 0) { el.innerHTML = '<p class="empty-state">Belum ada pendapatan.</p>'; return; }
  el.innerHTML = list.map(tx => txItemHTML(tx)).join('');
  el.querySelectorAll('.btn-delete').forEach(btn =>
    btn.addEventListener('click', () => handleDelete(btn.dataset.id))
  );
}

// ── Expense List ───────────────────────────────────────────
function renderExpenseList() {
  const el = document.getElementById('expenseList');
  const list = transactions.filter(t => t.type === 'Pengeluaran').slice().sort((a,b) => b.date.localeCompare(a.date));
  if (list.length === 0) { el.innerHTML = '<p class="empty-state">Belum ada pengeluaran.</p>'; return; }
  el.innerHTML = list.map(tx => txItemHTML(tx)).join('');
  el.querySelectorAll('.btn-delete').forEach(btn =>
    btn.addEventListener('click', () => handleDelete(btn.dataset.id))
  );
}

function txItemHTML(tx) {
  const cat     = getCatMeta(tx.category);
  const icon    = ICON_MAP[cat.icon] || cat.icon || '•';
  const isInc   = tx.type === 'Pendapatan';
  return `<div class="transaction-item" style="border-left-color:${cat.color}">
    <div class="tx-info">
      <span class="tx-name">${escapeHTML(tx.name)}</span>
      <div class="tx-meta">
        <span class="tx-badge" style="background:${cat.color}">${icon} ${escapeHTML(tx.category)}</span>
        <span>${formatDate(tx.date)}</span>
      </div>
    </div>
    <span class="tx-amount ${isInc ? 'income' : 'expense'}">${isInc ? '+' : '-'} ${formatRupiah(tx.amount)}</span>
    <button class="btn-delete" data-id="${tx.id}" title="Hapus" aria-label="Hapus">🗑️</button>
  </div>`;
}

// ── Report ─────────────────────────────────────────────────
function renderReport() {
  const el    = document.getElementById('reportList');
  const empty = document.getElementById('reportEmpty');
  let list = transactions.slice().sort((a,b) => b.date.localeCompare(a.date));
  if (reportFilter !== 'Semua') list = list.filter(t => t.type === reportFilter);
  if (reportMonth) list = list.filter(t => t.date.startsWith(reportMonth));
  if (list.length === 0) {
    el.innerHTML = '';
    empty.style.display = 'block';
    return;
  }
  empty.style.display = 'none';
  el.innerHTML = list.map(tx => txItemHTML(tx)).join('');
  el.querySelectorAll('.btn-delete').forEach(btn =>
    btn.addEventListener('click', () => handleDelete(btn.dataset.id))
  );
}

// ── Dashboard Charts ───────────────────────────────────────
function renderCharts() {
  const period = document.getElementById('dashPeriod').value; // 'all','month','week'
  let filtered = transactions.slice();
  const now = new Date();
  if (period === 'month') {
    const ym = now.toISOString().slice(0,7);
    filtered = filtered.filter(t => t.date.startsWith(ym));
  } else if (period === 'week') {
    const weekAgo = new Date(now - 7*24*60*60*1000).toISOString().slice(0,10);
    filtered = filtered.filter(t => t.date >= weekAgo);
  }

  const income  = filtered.filter(t => t.type === 'Pendapatan').reduce((s,t) => s+t.amount, 0);
  const expense = filtered.filter(t => t.type === 'Pengeluaran').reduce((s,t) => s+t.amount, 0);

  document.getElementById('dashIncome').textContent  = formatRupiah(income);
  document.getElementById('dashExpense').textContent = formatRupiah(expense);
  document.getElementById('dashBalance').textContent = formatRupiah(Math.abs(income - expense));
  document.getElementById('dashBalance').className   = 'dash-val ' + (income >= expense ? 'income' : 'expense');

  renderPieChart({
    txList: filtered.filter(t => t.type === 'Pengeluaran'),
    canvasId: 'spendingChart', emptyId: 'chartEmpty', ref: 'expense',
  });
  renderPieChart({
    txList: filtered.filter(t => t.type === 'Pendapatan'),
    canvasId: 'incomeChart', emptyId: 'incomeChartEmpty', ref: 'income',
  });

  // Recent 5 transactions
  const recentEl = document.getElementById('recentList');
  const recent   = transactions.slice().sort((a,b) => b.date.localeCompare(a.date)).slice(0,5);
  if (recent.length === 0) { recentEl.innerHTML = '<p class="empty-state">Belum ada transaksi.</p>'; return; }
  recentEl.innerHTML = recent.map(tx => txItemHTML(tx)).join('');
  recentEl.querySelectorAll('.btn-delete').forEach(btn =>
    btn.addEventListener('click', () => handleDelete(btn.dataset.id))
  );
}

function renderPieChart({ txList, canvasId, emptyId, ref }) {
  const canvas  = document.getElementById(canvasId);
  const emptyEl = document.getElementById(emptyId);
  const totals  = {};
  txList.forEach(tx => { totals[tx.category] = (totals[tx.category] || 0) + tx.amount; });
  const labels  = Object.keys(totals);
  const data    = Object.values(totals);
  const colors  = labels.map(l => getCatMeta(l).color || '#94a3b8');
  const hasData = labels.length > 0;
  canvas.style.display  = hasData ? 'block' : 'none';
  emptyEl.style.display = hasData ? 'none'  : 'block';
  const existing = ref === 'expense' ? expenseChart : incomeChart;
  if (!hasData) {
    if (existing) existing.destroy();
    if (ref === 'expense') expenseChart = null; else incomeChart = null;
    return;
  }
  if (existing) {
    existing.data.labels = labels;
    existing.data.datasets[0].data = data;
    existing.data.datasets[0].backgroundColor = colors;
    existing.update(); return;
  }
  const instance = new Chart(canvas, {
    type: 'pie',
    data: { labels, datasets: [{ data, backgroundColor: colors, borderWidth: 2, borderColor: 'transparent', hoverOffset: 8 }] },
    options: {
      responsive: true,
      plugins: {
        legend: { position: 'bottom', labels: { padding: 14, font: { size: 12 }, usePointStyle: true } },
        tooltip: { callbacks: { label(ctx) {
          const total = ctx.dataset.data.reduce((a,b) => a+b, 0);
          return ' ' + formatRupiah(ctx.parsed) + ' (' + ((ctx.parsed/total)*100).toFixed(1) + '%)';
        }}},
      },
    },
  });
  if (ref === 'expense') expenseChart = instance; else incomeChart = instance;
}


// ── Category CRUD ──────────────────────────────────────────
function renderCategoryList() {
  const el   = document.getElementById('categoryList');
  const list = categories.filter(c => c.type === catFilter);
  if (list.length === 0) { el.innerHTML = '<p class="empty-state">Belum ada kategori.</p>'; return; }
  el.innerHTML = list.map(c => {
    const icon = ICON_MAP[c.icon] || c.icon || '•';
    return `<div class="cat-item">
      <span class="cat-swatch" style="background:${c.color}">${icon}</span>
      <span class="cat-name">${escapeHTML(c.name)}</span>
      <span class="cat-type-badge ${c.type === 'Pendapatan' ? 'income' : 'expense'}">${c.type}</span>
      <div class="cat-actions">
        <button class="btn-cat-edit" data-id="${c.id}" title="Edit">✏️</button>
        <button class="btn-cat-del"  data-id="${c.id}" title="Hapus">🗑️</button>
      </div>
    </div>`;
  }).join('');
  el.querySelectorAll('.btn-cat-edit').forEach(btn =>
    btn.addEventListener('click', () => startEditCategory(btn.dataset.id))
  );
  el.querySelectorAll('.btn-cat-del').forEach(btn =>
    btn.addEventListener('click', () => deleteCategory(btn.dataset.id))
  );
}

async function handleCategorySubmit(e) {
  e.preventDefault();
  if (!currentUser) return;
  const name  = document.getElementById('catName').value.trim();
  const type  = document.getElementById('catType').value;
  const icon  = document.getElementById('catIcon').value.trim() || 'plus';
  const color = document.getElementById('catColor').value;
  const errEl = document.getElementById('err-catName');
  if (!name) { errEl.textContent = 'Nama kategori wajib diisi.'; return; }
  errEl.textContent = '';
  const btn = document.getElementById('btnSaveCategory');
  btn.disabled = true;
  try {
    if (editingCatId) {
      await updateDoc(doc(db, 'users', currentUser.uid, 'categories', editingCatId), { name, type, icon, color });
      editingCatId = null;
      btn.textContent = '+ Tambah Kategori';
    } else {
      await addDoc(collection(db, 'users', currentUser.uid, 'categories'), { name, type, icon, color });
    }
    e.target.reset();
    document.getElementById('catColor').value = '#6366f1';
  } catch (err) { console.error('save category:', err); alert('Gagal menyimpan kategori.'); }
  finally { btn.disabled = false; }
}

function startEditCategory(id) {
  const cat = categories.find(c => c.id === id);
  if (!cat) return;
  editingCatId = id;
  document.getElementById('catName').value  = cat.name;
  document.getElementById('catType').value  = cat.type;
  document.getElementById('catIcon').value  = cat.icon || '';
  document.getElementById('catColor').value = cat.color || '#6366f1';
  document.getElementById('btnSaveCategory').textContent = '💾 Simpan Perubahan';
  document.getElementById('catName').focus();
}

async function deleteCategory(id) {
  if (!currentUser || !confirm('Hapus kategori ini?')) return;
  try { await deleteDoc(doc(db, 'users', currentUser.uid, 'categories', id)); }
  catch (err) { console.error('delete category:', err); alert('Gagal menghapus.'); }
}

// ── Transaction Submit ─────────────────────────────────────
async function handleIncomeSubmit(e) {
  e.preventDefault();
  if (!validateTxForm('income')) return;
  await saveTx({
    type:     'Pendapatan',
    name:     document.getElementById('incomeName').value.trim(),
    amount:   parseInt(rawIncomeAmt, 10),
    category: stripCategoryEmoji(document.getElementById('incomeCategory').value),
    date:     document.getElementById('incomeDate').value,
  }, 'income');
}

async function handleExpenseSubmit(e) {
  e.preventDefault();
  if (!validateTxForm('expense')) return;
  await saveTx({
    type:     'Pengeluaran',
    name:     document.getElementById('expenseName').value.trim(),
    amount:   parseInt(rawExpenseAmt, 10),
    category: stripCategoryEmoji(document.getElementById('expenseCategory').value),
    date:     document.getElementById('expenseDate').value,
  }, 'expense');
}

async function saveTx(tx, prefix) {
  if (!currentUser) return;
  const btn = document.querySelector(`#${prefix}Form button[type=submit]`);
  btn.disabled = true; btn.textContent = 'Menyimpan...';
  try {
    await addDoc(collection(db, 'users', currentUser.uid, 'transactions'), { ...tx, createdAt: Date.now() });
    document.getElementById(`${prefix}Form`).reset();
    if (prefix === 'income')  { rawIncomeAmt  = ''; document.getElementById('incomeDate').value  = ''; }
    if (prefix === 'expense') { rawExpenseAmt = ''; document.getElementById('expenseDate').value = ''; }
    populateCategorySelect(`${prefix}Category`, tx.type);
  } catch (err) { console.error('saveTx:', err); alert('Gagal menyimpan transaksi.'); }
  finally { btn.disabled = false; btn.textContent = prefix === 'income' ? '+ Tambah Pendapatan' : '+ Tambah Pengeluaran'; }
}

async function handleDelete(id) {
  if (!currentUser) return;
  try { await deleteDoc(doc(db, 'users', currentUser.uid, 'transactions', id)); }
  catch (err) { console.error('delete tx:', err); alert('Gagal menghapus.'); }
}

// ── Validation ─────────────────────────────────────────────
function validateTxForm(prefix) {
  let ok = true;
  const fields = [
    { id: `${prefix}Name`,     errId: `err-${prefix}Name`,     msg: 'Nama wajib diisi.' },
    { id: `${prefix}Category`, errId: `err-${prefix}Category`, msg: 'Pilih kategori.' },
    { id: `${prefix}Date`,     errId: `err-${prefix}Date`,     msg: 'Tanggal wajib diisi.' },
  ];
  fields.forEach(({ id, errId, msg }) => {
    const el = document.getElementById(id);
    const er = document.getElementById(errId);
    if (!el.value.trim()) { el.classList.add('invalid'); er.textContent = msg; ok = false; }
    else { el.classList.remove('invalid'); er.textContent = ''; }
  });
  const rawAmt = prefix === 'income' ? rawIncomeAmt : rawExpenseAmt;
  const amtWrap = document.getElementById(`${prefix}Amount`).closest('.amount-wrapper');
  const amtErr  = document.getElementById(`err-${prefix}Amount`);
  if (!rawAmt || isNaN(parseInt(rawAmt,10)) || parseInt(rawAmt,10) <= 0) {
    amtWrap.classList.add('invalid'); amtErr.textContent = 'Jumlah wajib diisi dan > 0.'; ok = false;
  } else { amtWrap.classList.remove('invalid'); amtErr.textContent = ''; }
  return ok;
}


// ── User Management ────────────────────────────────────────
async function renderUsers() {
  if (currentUserRole !== 'admin') {
    document.getElementById('userTable').innerHTML = '<p class="empty-state">Akses ditolak. Hanya admin.</p>';
    return;
  }
  const query_str = (document.getElementById('userSearch').value || '').toLowerCase();
  try {
    const snap  = await getDocs(collection(db, 'appUsers'));
    let users   = snap.docs.map(d => d.data());
    if (query_str) users = users.filter(u =>
      (u.displayName || '').toLowerCase().includes(query_str) ||
      (u.email || '').toLowerCase().includes(query_str)
    );
    if (users.length === 0) {
      document.getElementById('userTable').innerHTML = '<p class="empty-state">Tidak ada user ditemukan.</p>';
      return;
    }
    const rows = users.map(u => `
      <tr>
        <td>
          <div class="user-cell">
            ${u.photoURL ? `<img src="${escapeHTML(u.photoURL)}" class="user-avatar-sm" alt="" />` : '<span class="user-avatar-sm placeholder">👤</span>'}
            <div>
              <div class="user-cell-name">${escapeHTML(u.displayName || '-')}</div>
              <div class="user-cell-email">${escapeHTML(u.email || '-')}</div>
            </div>
          </div>
        </td>
        <td>
          <select class="role-select" data-uid="${u.uid}" ${u.email === ADMIN_EMAIL ? 'disabled' : ''}>
            <option value="admin"  ${u.role === 'admin'  ? 'selected' : ''}>👑 Admin</option>
            <option value="user"   ${u.role === 'user'   ? 'selected' : ''}>👤 User</option>
            <option value="viewer" ${u.role === 'viewer' ? 'selected' : ''}>👁️ Viewer</option>
          </select>
        </td>
        <td>
          <select class="status-select" data-uid="${u.uid}" ${u.email === ADMIN_EMAIL ? 'disabled' : ''}>
            <option value="active"   ${u.status === 'active'   ? 'selected' : ''}>✅ Aktif</option>
            <option value="inactive" ${u.status === 'inactive' ? 'selected' : ''}>🚫 Nonaktif</option>
          </select>
        </td>
        <td class="user-date">${u.firstLogin ? new Date(u.firstLogin).toLocaleDateString('id-ID') : '-'}</td>
        <td class="user-date">${u.lastLogin  ? new Date(u.lastLogin).toLocaleDateString('id-ID')  : '-'}</td>
        <td>
          <button class="btn-save-user" data-uid="${u.uid}" ${u.email === ADMIN_EMAIL ? 'disabled' : ''}>💾 Simpan</button>
        </td>
      </tr>`).join('');

    document.getElementById('userTable').innerHTML = `
      <table class="user-table">
        <thead><tr>
          <th>User</th><th>Role</th><th>Status</th><th>First Login</th><th>Last Login</th><th>Aksi</th>
        </tr></thead>
        <tbody>${rows}</tbody>
      </table>`;

    document.querySelectorAll('.btn-save-user').forEach(btn => {
      btn.addEventListener('click', async () => {
        const uid    = btn.dataset.uid;
        const role   = document.querySelector(`.role-select[data-uid="${uid}"]`).value;
        const status = document.querySelector(`.status-select[data-uid="${uid}"]`).value;
        btn.disabled = true; btn.textContent = '...';
        try {
          await updateDoc(doc(db, 'appUsers', uid), { role, status });
          btn.textContent = '✅ Tersimpan';
          setTimeout(() => { btn.disabled = false; btn.textContent = '💾 Simpan'; }, 1500);
        } catch (err) { console.error('save user:', err); btn.disabled = false; btn.textContent = '💾 Simpan'; }
      });
    });
  } catch (err) { console.error('renderUsers:', err); }
}

// ── Export Excel ───────────────────────────────────────────
function handleExport() {
  let list = transactions.slice().sort((a,b) => a.date.localeCompare(b.date));
  if (reportFilter !== 'Semua') list = list.filter(t => t.type === reportFilter);
  if (reportMonth) list = list.filter(t => t.date.startsWith(reportMonth));
  if (list.length === 0) { alert('Tidak ada data untuk di-export.'); return; }
  const header = ['Tanggal','Nama Item','Tipe','Kategori','Jumlah (Rp)'];
  const rows   = list.map(t => [formatDate(t.date), t.name, t.type, t.category, t.amount]);
  const ws = XLSX.utils.aoa_to_sheet([header, ...rows]);
  ws['!cols'] = [{ wch:14 },{ wch:30 },{ wch:14 },{ wch:16 },{ wch:18 }];
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Transaksi');
  XLSX.writeFile(wb, 'finance-tracker-' + todayISO() + '.xlsx');
}

// ── Amount Mask ────────────────────────────────────────────
function bindAmountMask(inputId, getVal, setVal) {
  const input = document.getElementById(inputId);
  input.addEventListener('input', () => {
    const digits = input.value.replace(/\D/g, '');
    setVal(digits);
    input.value = digits === '' ? '' : parseInt(digits, 10).toLocaleString('id-ID');
    input.closest('.amount-wrapper').classList.remove('invalid');
    const errEl = document.getElementById('err-' + inputId);
    if (errEl) errEl.textContent = '';
  });
  input.addEventListener('keydown', e => {
    const allowed = ['Backspace','Delete','ArrowLeft','ArrowRight','ArrowUp','ArrowDown','Tab','Home','End'];
    if (!allowed.includes(e.key) && !/^\d$/.test(e.key)) e.preventDefault();
  });
}

// ── Helpers ────────────────────────────────────────────────
function formatRupiah(n) { return 'Rp ' + (n || 0).toLocaleString('id-ID'); }
function formatDate(iso) {
  if (!iso) return '';
  const [y,m,d] = iso.split('-');
  return d + '/' + m + '/' + y;
}
function todayISO() { return new Date().toISOString().split('T')[0]; }
// Strip leading emoji + space from datalist option value (e.g. "🍽️ Makan" → "Makan")
function stripCategoryEmoji(val) {
  if (!val) return val;
  return val.replace(/^[\p{Emoji}\p{So}\s]+/u, '').trim();
}
function escapeHTML(str) {
  return String(str)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;')
    .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#039;');
}

