import express from "express";
import taskRoutes from "./routes/tasks";

const app = express();
const rawPort = process.env.PORT;
const PORT = rawPort === undefined ? 3000 : Number(rawPort);

if (!Number.isInteger(PORT) || PORT < 0 || PORT > 65535) {
  throw new Error(`Invalid PORT value: ${rawPort}`);
}
// Middleware
app.use(express.json());

// Health check endpoint
app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

// Task routes
app.use("/api", taskRoutes);

// Start server (only when not imported for testing)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Task Management API running on port ${PORT}`);
  });
}

export default app;
