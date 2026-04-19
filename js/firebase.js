/* ===========================
   Firebase Config & Init
=========================== */
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js";
import {
  getFirestore,
  collection,
  addDoc,
  deleteDoc,
  doc,
  onSnapshot,
  query,
  orderBy,
} from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";
import {
  getAuth,
  GoogleAuthProvider,
  signInWithPopup,
  signOut,
  onAuthStateChanged,
} from "https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js";

const firebaseConfig = {
  apiKey:            "AIzaSyDC2avZUyiK8WEWPL1tvPuCEWmKcwc2fCY",
  authDomain:        "fin-track-2604.firebaseapp.com",
  projectId:         "fin-track-2604",
  storageBucket:     "fin-track-2604.firebasestorage.app",
  messagingSenderId: "761509708838",
  appId:             "1:761509708838:web:d8b5a1f97e10b1b36c92e7",
  measurementId:     "G-M635VVWLYP",
};

const app      = initializeApp(firebaseConfig);
const db       = getFirestore(app);
const auth     = getAuth(app);
const provider = new GoogleAuthProvider();
provider.setCustomParameters({ prompt: 'select_account' });

export {
  db, auth, provider,
  collection, addDoc, deleteDoc, doc,
  onSnapshot, query, orderBy,
  signInWithPopup, signOut, onAuthStateChanged,
};
