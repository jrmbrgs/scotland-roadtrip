import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { createRequire } from 'module';

const require = createRequire(import.meta.url);
const serviceAccount = require('./.creds/scotland-e21ec-firebase-adminsdk-fbsvc-dde81226ee.json');

initializeApp({
  credential: cert(serviceAccount),
  databaseURL: 'https://scotland-e21ec-default-rtdb.europe-west1.firebasedatabase.app'
});

const uid = process.argv[2];
if (!uid) {
  console.error('Usage: node set-admin.mjs <USER_UID>');
  process.exit(1);
}

getAuth().setCustomUserClaims(uid, { admin: true })
  .then(() => {
    console.log(`Custom claim "admin: true" set for user ${uid}`);
    console.log('The user must log out and log back in for the claim to take effect.');
    process.exit(0);
  })
  .catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
  });
