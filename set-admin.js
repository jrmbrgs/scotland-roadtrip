// Run once to set the admin custom claim on your Firebase user.
// Usage: node set-admin.js <USER_UID>
//
// Prerequisites:
//   npm install firebase-admin
//   Download your service account key from Firebase Console:
//     Project Settings → Service accounts → Generate new private key
//   Save it as service-account.json in this directory

const admin = require('firebase-admin');
const serviceAccount = require('./.creds/scotland-e21ec-firebase-adminsdk-fbsvc-dde81226ee.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://scotland-e21ec-default-rtdb.europe-west1.firebasedatabase.app'
});

const uid = process.argv[2];
if (!uid) {
  console.error('Usage: node set-admin.js <USER_UID>');
  process.exit(1);
}

admin.auth().setCustomUserClaims(uid, { admin: true })
  .then(() => {
    console.log(`Custom claim "admin: true" set for user ${uid}`);
    console.log('The user must log out and log back in for the claim to take effect.');
    process.exit(0);
  })
  .catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
  });
