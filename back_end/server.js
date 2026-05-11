const express = require("express");
const cors = require("cors");
const path = require("path");
require("dotenv").config();

// Import routes
const authRoutes = require("./routes/auth");
const userRoutes = require("./routes/users");
const clubRoutes = require("./routes/clubs");
const addeventRoutes = require("./routes/addevents");
const dashboardRoutes = require("./routes/dashboard");
const profileRoutes = require("./routes/profile");
const studentProfileRoutes = require("./routes/studentprofile");
const eventLikesRoutes = require("./routes/eventLikes");
const participateRoutes = require("./routes/participate");

const app = express();

// ✅ Simplified CORS (works with emulator, Postman, browser)
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

// Log incoming requests
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  console.log("Origin:", req.headers.origin);
  next();
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Root route
app.get("/", (req, res) => {
  res.json({
    message: "College Event Management API is running!",
    version: "1.0.0",
  });
});

// API routes
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api", clubRoutes);
app.use("/api", addeventRoutes);
app.use("/api", dashboardRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/student/profile", studentProfileRoutes);
app.use("/api/event-likes", eventLikesRoutes);
app.use("/api/participate", participateRoutes);

// Test endpoints
app.get("/api/test-db", async (req, res) => {
  try {
    const db = require("./config/database");
    const [results] = await db.execute("SELECT 1 as test");
    res.json({
      message: "Database connection successful",
database: process.env.MYSQLDATABASE,
      data: results,
    });
  } catch (error) {
    res.status(500).json({ error: "Database connection failed: " + error.message });
  }
});

app.get("/api/test-cors", (req, res) => {
  res.json({
    message: "CORS test successful!",
    origin: req.headers.origin,
    timestamp: new Date().toISOString(),
  });
});

// 404 handler
app.use("*", (req, res) => {
  res.status(404).json({
    message: "Route not found",
    requestedUrl: req.originalUrl,
  });
});

// Error handler
app.use((error, req, res, next) => {
  console.error("❌ Server error:", error);
  res.status(500).json({
    message: "Internal server error",
    error: process.env.NODE_ENV === "development" ? error.message : undefined,
  });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📍 Local: http://localhost:${PORT}`);
  console.log(`📍 Emulator: https://campus-connect-p1ow.onrender.com//:${PORT}`);
  console.log("✅ CORS enabled for all origins (dev mode)");
});
