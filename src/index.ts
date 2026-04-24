import express from "express";

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Health check endpoint
app.get("/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// Start server (only when not imported for testing)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Task Management API running on port ${PORT}`);
  });
}

export default app;
