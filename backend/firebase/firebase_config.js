const admin = require('firebase-admin');
const path = require('path');

function initFirebase() {
  if (admin.apps.length > 0) return admin.app();

  try {
    const serviceAccountPath = path.resolve(
      process.env.GOOGLE_APPLICATION_CREDENTIALS || './firebase/serviceAccountKey.json'
    );

    const serviceAccount = require(serviceAccountPath);

    return admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  } catch (err) {
    console.error('Firebase initialization failed:', err.message);
    throw err;
  }
}

function getFirestore() {
  initFirebase();
  return admin.firestore();
}

module.exports = { initFirebase, getFirestore };
