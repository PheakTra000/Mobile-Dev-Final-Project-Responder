const admin = require('firebase-admin');
const path = require('path');

function initFirebase() {
  if (admin.apps.length > 0) return admin.app();

  const serviceAccountPath = path.resolve(
    process.env.GOOGLE_APPLICATION_CREDENTIALS || './firebase/serviceAccountKey.json'
  );

  const serviceAccount = require(serviceAccountPath);

  return admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

function getFirestore() {
  initFirebase();
  return admin.firestore();
}

module.exports = { initFirebase, getFirestore };
