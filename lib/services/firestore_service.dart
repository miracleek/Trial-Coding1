import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ── Collections ──────────────────────────────────────────
  static CollectionReference get _sharedCats =>
      _db.collection('sharedCategories');

  static CollectionReference _transactions(String uid) =>
      _db.collection('users').doc(uid).collection('transactions');

  static DocumentReference _appUser(String uid) =>
      _db.collection('appUsers').doc(uid);

  // ── User Registration ─────────────────────────────────────
  static Future<void> registerOrUpdateUser(User user) async {
    final ref = _appUser(user.uid);
    final snap = await ref.get();
    final now = DateTime.now().millisecondsSinceEpoch;
    const adminEmail = 'eduworkrin@gmail.com';

    if (!snap.exists) {
      await ref.set({
        'uid': user.uid,
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
        'role': user.email == adminEmail ? 'admin' : 'user',
        'status': 'active',
        'firstLogin': now,
        'lastLogin': now,
      });
    } else {
      await ref.update({
        'lastLogin': now,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
      });
    }
  }

  // ── User Role ─────────────────────────────────────────────
  static Future<String> getUserRole(String uid) async {
    try {
      final snap = await _appUser(uid).get();
      if (snap.exists) {
        return (snap.data() as Map<String, dynamic>)['role'] ?? 'user';
      }
    } catch (_) {}
    return 'user';
  }

  // ── Categories (real-time) ────────────────────────────────
  static Stream<List<Map<String, dynamic>>> categoriesStream() {
    return _sharedCats.snapshots().map(
      (snap) =>
          snap.docs
              .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
              .toList()
            ..sort(
              (a, b) => (a['name'] as String).compareTo(b['name'] as String),
            ),
    );
  }

  // ── Transactions (real-time) ──────────────────────────────
  static Stream<List<Map<String, dynamic>>> transactionsStream(String uid) {
    return _transactions(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
              .toList(),
        );
  }

  // ── Add Transaction ───────────────────────────────────────
  static Future<void> addTransaction({
    required String uid,
    required String name,
    required double amount,
    required String category,
    required String date, // YYYY-MM-DD
    required String type, // 'Pendapatan' | 'Pengeluaran'
  }) async {
    await _transactions(uid).add({
      'name': name,
      'amount': amount,
      'category': category,
      'date': date,
      'type': type,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ── Delete Transaction ────────────────────────────────────
  static Future<void> deleteTransaction(String uid, String txId) async {
    await _transactions(uid).doc(txId).delete();
  }

  // ── Helper: format DateTime to YYYY-MM-DD ─────────────────
  static String formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  // ── Helper: parse YYYY-MM-DD to DateTime ──────────────────
  static DateTime parseDate(String s) => DateTime.parse(s);
}
