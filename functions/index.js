const admin = require("firebase-admin");
const functions = require("firebase-functions");

admin.initializeApp();

const messaging = admin.messaging();

exports.notifySubscribers = functions.https.onCall(async (data, _) => {
    try {
        await messaging.sendToDevice(data.targetDevices, {
            notification: {
                title: data.messageTitle,
                body: data.messageBody
            }
        });

        return true;
    } catch (ex) {
        return false;
    }
});

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
