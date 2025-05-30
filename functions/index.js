/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");


const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Cloud Firestore triggers ref: https://firebase.google.com/docs/functions/firestore-events
exports.myFunction = functions.firestore
  .document('chats/{messageId}')
  .onCreate((snapshot, context) => {
    // Return this function's promise, so this ensures the firebase function
    // will keep running, until the notification is scheduled.
    return admin.messaging().send({
      // Sending a notification message.
      notification: {
        title: snapshot.data()['username'],
        body: snapshot.data()['text'],
      },
      data: {
        // Data payload to be sent to the device.
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      topic: 'chat',
    });
  });
