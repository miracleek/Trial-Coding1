// Firebase Config and Exports
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js";
import { getAuth, GoogleAuthProvider, signInWithPopup, signOut, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js";
import { getFirestore, collection, addDoc, deleteDoc, doc, onSnapshot, query, orderBy, setDoc, getDoc, getDocs, updateDoc } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js";

const firebaseConfig = {
  apiKey: "AIzaSyDC2avZUyiK8WEWPL1tvPuCEWmKcwc2fCY",
  authDomain: "fin-track-2604.firebaseapp.com",
  projectId: "fin-track-2604",
  storageBucket: "fin-track-2604.firebasestorage.app",
  messagingSenderId: "761509708838",
  appId: "1:761509708838:web:d8b5a1f97e10b1b36c92e7",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const provider = new GoogleAuthProvider();

export { auth, db, provider, collection, addDoc, deleteDoc, doc, onSnapshot, query, orderBy, signInWithPopup, signOut, onAuthStateChanged, setDoc, getDoc, getDocs, updateDoc };
