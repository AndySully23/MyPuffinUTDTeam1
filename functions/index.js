/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const { onRequest } = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotification = functions.firestore
    .document('heart_rate/{docId}')
    .onCreate(async(snap) => {

        const newValue = snap.data();
        const userId = newValue.userId; // Assuming that the user ID is stored in the document.

        // Retrieve the user's token from Firestore.
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const token = userDoc.get('token');

        // Construct the notification payload.
        const payload = {
            notification: {
                title: 'New Data Added',
                body: 'A new document has been added to the collection.',
            },
        };

        const options = {
            priority: 'high',
        };

        // Send a notification to the user's device.
        if (token) {
            return admin.messaging().sendToDeviceGroup(token, payload);
        } else {
            console.log('Token not found for user:', userId);
            return null;
        }
    });