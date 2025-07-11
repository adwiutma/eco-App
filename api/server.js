const express = require("express");
const bodyParser = require("body-parser");
const { createQRISPayment, checkPaymentStatus } = require("./paymentHelper");
require("dotenv").config();

const app = express();
const PORT = 3000;

// Middleware
app.use(bodyParser.json());

// Endpoint to create QRIS payment
app.post("/create-qris-payment", async (req, res) => {
  try {
    const { amount } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ error: "Invalid amount" });
    }

    const payment = await createQRISPayment(amount);

    res.status(200).json({
      orderId: payment.orderId,
      qrisUrl: payment.qrisUrl,
    });
  } catch (error) {
    console.error("Error creating QRIS payment:", error);
    res.status(500).json({ error: "Failed to create QRIS payment" });
  }
});

// Endpoint to check payment status
app.get("/payment-status/:orderId", async (req, res) => {
  try {
    const { orderId } = req.params;

    if (!orderId) {
      return res.status(400).json({ error: "Order ID is required" });
    }

    const status = await checkPaymentStatus(orderId);

    res.status(200).json(status);
  } catch (error) {
    console.error("Error checking payment status:", error);
    res.status(500).json({ error: "Failed to check payment status" });
  }
});
console.log("Server Key Used:", process.env.MIDTRANS_SERVER_KEY);

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
