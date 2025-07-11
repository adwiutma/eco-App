/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

// Konfigurasi Nodemailer
const transporter = nodemailer.createTransport({
  service: "gmail", // Gunakan provider email Anda
  auth: {
    user: "akbarzaki842@gmail.com",
    pass: "pxuq ivin hqkx gdbx",
  },
});

// Firebase Function untuk mengirim OTP
exports.sendOtpEmail = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const otp = Math.floor(100000 + Math.random() * 900000).toString(); // OTP 6 digit

  const mailOptions = {
    from: "akbarzaki842@gmail.com",
    to: email,
    subject: "Your OTP Code",
    text: `Your OTP code is ${otp}. It will expire in 10 minutes.`,
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true, otp: otp }; // Kirim OTP balik jika diperlukan
  } catch (error) {
    throw new functions.https.HttpsError("failed-precondition", error.message);
  }
});
