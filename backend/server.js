const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });

const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const adminRoutes = require("./routes/adminRoutes");

const app = express();

// MongoDB connection cache for Vercel
let cached = global.mongoose;

if (!cached) {
    cached = global.mongoose = { conn: null, promise: null };
}

const connectDB = async () => {
    if (cached.conn) {
        return cached.conn;
    }

    if (!process.env.MONGO_URI) {
        throw new Error("MONGO_URI is not configured");
    }

    if (!cached.promise) {
        cached.promise = mongoose.connect(process.env.MONGO_URI, {
            serverSelectionTimeoutMS: 10000,
            family: 4
        }).then((mongooseInstance) => mongooseInstance)
          .catch((error) => {
              cached.promise = null;
              throw error;
          });
    }

    cached.conn = await cached.promise;
    return cached.conn;
};

// Middleware
const clientUrl = process.env.CLIENT_URL;
const allowedOrigins = [
    clientUrl,
    "http://localhost:5173",
    "http://localhost:3000",
    "http://127.0.0.1:5173",
].filter(Boolean);

app.use(cors({
    origin: (origin, callback) => {
        // Allow mobile apps, curl, Postman, and server-to-server calls with no origin header
        if (!origin) return callback(null, true);
        if (
            process.env.NODE_ENV !== "production" ||
            allowedOrigins.length === 0 ||
            allowedOrigins.includes(origin) ||
            origin.endsWith(".vercel.app")
        ) {
            return callback(null, true);
        }
        return callback(null, true);
    },
    credentials: true,
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Ensure MongoDB is connected before processing API requests
app.use(async (req, res, next) => {
    try {
        await connectDB();
        next();
    } catch (error) {
        console.error("MongoDB connection error:", error.message);
        res.status(503).json({ message: "Database connection failed" });
    }
});

// API routes
app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);
app.use("/api/admin", adminRoutes);

// Global error handler
app.use((err, req, res, next) => {
    console.error("Global error:", err.message);
    res.status(500).json({ message: "Something went wrong!" });
});

// Local development only
if (require.main === module) {
    const PORT = process.env.PORT || 5000;

    connectDB()
        .then(() => {
            console.log("✅ Connected to MongoDB Atlas");
            app.listen(PORT, () => {
                console.log(`🚀 Server running on http://localhost:${PORT}`);
            });
        })
        .catch((err) => {
            console.error("❌ MongoDB Atlas connection error on startup:", err.message);
            app.listen(PORT, () => {
                console.log(`🚀 Server running on http://localhost:${PORT} (DB connection pending/retry)`);
            });
        });
}

// Export Express app for Vercel
module.exports = app;