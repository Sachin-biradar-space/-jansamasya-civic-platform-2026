# JanSamasya – Complete Technical Architecture & Project Segmentation Document

> **Project Name:** JanSamasya – A Civic Issue Reporting and Tracking Platform  
> **Tagline:** *"Report. Track. Resolve. Build a Better Community."*  
> **Architecture Pattern:** Decoupled Client-Server (MERN Stack: MongoDB, Express.js, React.js, Node.js)  
> **Target Audience:** MCA / Computer Science Students, Academic Evaluators, and Technical Reviewers  

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Project Folder Structure](#2-project-folder-structure)
3. [Frontend Analysis](#3-frontend-analysis)
4. [Backend Analysis](#4-backend-analysis)
5. [Database Analysis](#5-database-analysis)
6. [Authentication and User Roles](#6-authentication-and-user-roles)
7. [Complete Functionality & Feature Classification](#7-complete-functionality--feature-classification)
8. [API Documentation](#8-api-documentation)
9. [Complete Step-by-Step Data Flow](#9-complete-step-by-step-data-flow)
10. [File & Media Storage](#10-file--media-storage)
11. [Execution and Deployment Guide](#11-execution-and-deployment-guide)
12. [Testing, Security Observations & Limitations](#12-testing-security-observations--limitations)

---

## 1. Project Overview

### 1.1 Project Purpose
**JanSamasya** (formerly CityCare) is a full-stack civic grievance reporting and municipal resolution tracking web application. It connects local citizens directly with municipal administrators. Citizens can report infrastructure defects (such as potholes, street lighting failures, open garbage dumps, and water/drainage issues) along with location information and photographic evidence. Municipal administrators can review incoming complaints filtered by geographical area, track resolution progress, and update complaint lifecycles in real time.

### 1.2 Main Problem It Solves
Traditional civic grievance mechanisms in municipal corporations often suffer from:
1. **Lack of transparency:** Citizens submit complaints without knowing who received them or whether work has commenced.
2. **Geographic routing bottlenecks:** Complaints are often dispatched to incorrect zonal offices without proper state/area tagging.
3. **Absence of photo evidence:** Vague verbal descriptions lead to delayed verification by field engineers.
4. **No centralized audit view:** Regional administrators lack consolidated metrics showing pending, active, and resolved civic works.

JanSamasya solves these issues by providing:
- **Role-based portals** for citizens and regional administrators.
- **Geographic tagging** (State and Area/District) attached to both user profiles and grievance tickets.
- **Direct image uploads** giving authorities visual proof of the issue.
- **Status tracking** across three verified operational stages: `pending` → `in-progress` → `resolved`.

### 1.3 Technologies and Frameworks Used

| Layer | Technology | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **Client UI Library** | React.js | `^19.1.0` | Declarative component-based user interface |
| **Build & Dev Tool** | Vite | `^6.3.5` | Next-generation ESM bundler and HMR development server |
| **CSS Framework** | Tailwind CSS | `^3.4.17` | Utility-first responsive CSS styling |
| **CSS Post-Processors**| PostCSS & Autoprefixer | `^8.4.49` / `^10.4.20` | CSS parsing, prefixing, and pipeline compilation |
| **Client Routing** | React Router DOM | `^6.30.1` | Single Page Application (SPA) client-side routing |
| **HTTP Client** | Axios | `^1.13.6` | Promise-based asynchronous HTTP requests to backend |
| **Client Token Decode**| jwt-decode | `^4.0.0` | Client-side JWT parsing for role and session state |
| **UI Iconography** | Lucide React | `^0.516.0` | Lightweight SVG icons |
| **Server Runtime** | Node.js | `v20+` / `v24+` | Non-blocking asynchronous JavaScript server environment |
| **Web Server Framework**| Express.js | `^5.1.0` | REST API routing, middleware chaining, HTTP request handling |
| **Database Engine** | MongoDB (Community Server)| `v7+` | Document-oriented NoSQL persistence store |
| **ODM Library** | Mongoose | `^8.16.0` | Schema validation, type casting, query building, relations |
| **Authentication** | JSON Web Tokens (`jsonwebtoken`)| `^9.0.2` | Stateless signed bearer token authentication |
| **Password Security** | BcryptJS (`bcryptjs`) | `^3.0.2` | One-way cryptographic salting and hashing (10 rounds) |
| **Multipart Uploads** | Multer | `^2.0.1` | Streaming multipart/form-data handler for image files |
| **CORS Middleware** | `cors` | `^2.8.5` | Cross-Origin Resource Sharing origin filtering |
| **Environment Config** | `dotenv` | `^16.5.0` | Loading environment variables from local `.env` file |
| **Containerization** | Docker & Docker Compose | Compose v2 | Container packaging for frontend, backend, and MongoDB |
| **Production Web Server**| Nginx (Alpine) | - | Reverse proxy and static file hosting for frontend Docker build |

### 1.4 Overall Architecture

The project follows a decoupled **3-Tier Client-Server Architecture**:

```
+---------------------------------------------------------------------------------------+
|                                    PRESENTATION TIER                                  |
|  React 19 Single Page Application (SPA) - Vite Dev Server (:5173) or Nginx (:3000)   |
|  - AuthContext (Session state & localStorage token management)                        |
|  - Public Pages: Home, Login, Signup                                                  |
|  - Citizen Pages: Report Issue, My Reports, User Profile                              |
|  - Admin Pages: Admin Dashboard, All Reports, Update Status                           |
+-------------------------------------------+-------------------------------------------+
                                            |
                         HTTP / REST API    | JSON / FormData
                         Bearer JWT Header  | Reverse Proxy /api & /uploads
                                            v
+---------------------------------------------------------------------------------------+
|                                    APPLICATION TIER                                   |
|  Node.js / Express 5 REST API Server (:5000)                                          |
|  - server.js (CORS origin filter, URL-encoded/JSON parsers, Static uploads route)    |
|  - Routes: /api/auth, /api/user, /api/admin                                           |
|  - Middleware: authMiddleware (JWT verify), requireRole (RBAC), upload (Multer disk)  |
|  - Controllers: authController, userController, adminController                       |
+-------------------------------------------+-------------------------------------------+
                                            |
                         Mongoose ODM       | BSON Documents
                         TCP Port :27017    | Family 4 (IPv4)
                                            v
+---------------------------------------------------------------------------------------+
|                                      DATA TIER                                        |
|  MongoDB Server (:27017)                                                              |
|  - Database: fixmytown                                                                |
|  - Collections: users, reports                                                        |
|  - Filesystem Storage: backend/uploads/ (Local disk for submitted issue images)       |
+---------------------------------------------------------------------------------------+
```

---

## 2. Project Folder Structure

```
CityCare-main/
├── docker-compose.yml             # Multi-container orchestration definition
├── README.md                      # Root documentation with project setup and overview
├── JANSAAMASYA_PROJECT_SEGMENTATION.md # This comprehensive technical architecture document
├── backend/                       # Node.js + Express backend service
│   ├── .dockerignore              # Files ignored during backend Docker build
│   ├── .env                       # Local environment variables (PORT, MONGO_URI, JWT_SECRET)
│   ├── Dockerfile                 # Backend container image build instructions
│   ├── package.json               # Backend dependencies and scripts
│   ├── package-lock.json          # Locked dependency tree for backend
│   ├── server.js                  # Express entrypoint, database connection, middleware configuration
│   ├── controllers/               # Business logic handlers
│   │   ├── adminController.js     # Admin report querying, dashboard counters, status patching
│   │   ├── authController.js      # User registration, bcrypt hashing, credential check, JWT issuance
│   │   └── userController.js      # Citizen profile fetch, report creation, personal report queries
│   ├── middleware/                # Custom Express request interceptors
│   │   ├── authMiddleware.js      # JWT Bearer token validation and Role-Based Access Control (RBAC)
│   │   └── upload.js              # Multer disk-storage engine and image mimetype filter
│   ├── models/                    # Mongoose database models and schemas
│   │   ├── Report.js              # Civic issue schema (title, description, category, status, etc.)
│   │   └── User.js                # User identity schema (username, email, password, role, state, area)
│   ├── routes/                    # Express routing tables
│   │   ├── adminRoutes.js         # /api/admin/* endpoints
│   │   ├── authRoutes.js          # /api/auth/* endpoints
│   │   └── userRoutes.js          # /api/user/* endpoints
│   └── uploads/                   # Local persistent directory for user-uploaded issue photos
└── frontend/                      # React 19 + Vite frontend client
    ├── Dockerfile                 # Multi-stage production container build (Vite build -> Nginx)
    ├── eslint.config.js           # ESLint configuration with react-hooks and react-refresh rules
    ├── index.html                 # Single HTML entrypoint with viewport and title metadata
    ├── nginx.conf                 # Nginx proxy configuration for Docker deployment
    ├── package.json               # Frontend dependencies, build scripts, and dev tools
    ├── package-lock.json          # Locked dependency tree for frontend
    ├── postcss.config.js          # PostCSS 8 configuration connecting Tailwind CSS and Autoprefixer
    ├── README.md                  # Frontend feature walkthrough and development instructions
    ├── tailwind.config.js         # Tailwind CSS content scanner and styling configuration
    ├── vercel.json                # Optional Vercel deployment rewrite rules
    ├── vite.config.js             # Vite configuration with React plugin and local development proxy
    ├── public/                    # Unprocessed static web assets
    │   └── vite.svg               # Application browser favicon
    └── src/                       # React application source code
        ├── App.css                # Legacy sample styles (not imported by App.jsx)
        ├── App.jsx                # Root route definitions with BrowserRouter
        ├── index.css              # Global styles with Tailwind directives and custom button classes
        ├── main.jsx               # React DOM bootstrap mounting AuthProvider and App into #root
        ├── assets/                # Static visual assets
        │   └── react.svg          # Framework icon
        ├── components/            # Reusable UI widgets
        │   └── Navbar.jsx         # Global navigation bar with role-conditional links and logout
        ├── context/               # Global state providers
        │   └── AuthContext.jsx    # React Context managing user authentication state and JWT storage
        └── pages/                 # Full-page route components
            ├── AdminDashboard.jsx # Administrator KPI metric cards and operational summary
            ├── AllReports.jsx     # Regional complaint browser with area search filter for admins
            ├── Home.jsx           # Public promotional landing page with initiative overview
            ├── Login.jsx          # Role-aware authentication form for citizens and admins
            ├── MyReports.jsx      # Citizen personal history page showing report statuses
            ├── Report.jsx         # Citizen complaint filing form with multipart file upload
            ├── Signup.jsx         # Citizen and administrator registration form
            ├── UpdateReportStatus.jsx # Administrative panel to change report lifecycle stage
            └── UserProfile.jsx    # Authenticated user account summary and service zone details
```

---

## 3. Frontend Analysis

### 3.1 React Application Structure
The frontend is constructed using **React 19** with functional components and React Hooks (`useState`, `useEffect`, `useContext`, `useCallback`). It mounts onto a single DOM container `<div id="root"></div>` located inside `frontend/index.html`.

- **Entrypoint (`main.jsx`):** Wraps the entire application inside `<React.StrictMode>` and `<AuthProvider>`, ensuring that authentication state is available throughout the component tree before `<App />` renders.
- **Routing Root (`App.jsx`):** Encloses the layout in `<BrowserRouter>` (aliased as `Router`), renders the persistent `<Navbar />`, and mounts a `<Routes>` switch containing 9 routes.

### 3.2 Pages and Components
1. **`Navbar.jsx` (Global Navigation Component):**
   - Renders the brand logo (`JanSamasya`) and tagline.
   - Conditionally renders navigation links based on `user.role`:
     - If `user.role === "user"`: Shows *Report Issue*, *My Reports*, and *Profile*.
     - If `user.role === "admin"`: Shows *Dashboard*, *All Reports*, and *Update Status*.
     - If unauthenticated: Shows *Login* and *Sign Up* action buttons.
   - Displays a live status badge ("Citizen" or "Admin").
   - Provides a *Logout* button that calls `logout()` from `AuthContext` and redirects to `/login`.
2. **`Home.jsx` (Landing Page):**
   - Public view. If an authenticated user lands here, it automatically redirects them to `/profile`.
   - Displays promotional banners, initiative statistics, 3-step workflow descriptions, issue categories, and contact information.
3. **`Signup.jsx` (Registration Page):**
   - Captures `username`, `email`, `password`, `role` (Citizen / Municipal Administrator), `state` (dropdown of 28 Indian states), and optional `area`.
   - Sends a `POST` request to `/api/auth/signup` and redirects to `/login` upon success.
4. **`Login.jsx` (Sign-In Page):**
   - Captures `username`, `password`, and `role`.
   - Sends a `POST` request to `/api/auth/login`.
   - On success, stores the JWT via `login(token)` and routes administrators to `/all-reports` and citizens to `/my-reports`.
5. **`Report.jsx` (Citizen Issue Submission):**
   - Multipart form capturing `title`, `category` (9 categories: roads, sanitation, streetlights, water, parks, noise, utilities, safety, other), `description`, and an optional image attachment (`<input type="file" accept="image/*">`).
   - Uses native `FormData` to transmit binary files to `POST /api/user/report`.
6. **`MyReports.jsx` (Citizen Grievance History):**
   - Queries `GET /api/user/my-reports`.
   - Displays summary KPI cards for personal submissions (Total, Resolved, In Progress, Under Review).
   - Lists complaint cards with category emoji badges, submission dates, state/area tags, and uploaded evidence thumbnails.
7. **`AllReports.jsx` (Admin Complaint Catalog):**
   - Queries `GET /api/admin/reports` with optional query parameter `?area=...`.
   - Renders a live text filter allowing administrators to filter complaints by sub-district/area.
   - Shows report cards with MongoDB ObjectIds and direct links to update status.
8. **`UpdateReportStatus.jsx` (Admin Lifecycle Management):**
   - Renders an administrative form taking a `reportId` and a choice of 3 status radio buttons (`pending`, `in-progress`, `resolved`).
   - Submits `PUT /api/admin/report/:id/status` to update the issue status.
9. **`UserProfile.jsx` (Account Overview):**
   - Queries `GET /api/user/profile`.
   - Displays authenticated citizen details: username, email, state, district/area, role privileges, and verification status.
10. **`AdminDashboard.jsx` (Admin Analytics & Health):**
    - Queries `GET /api/admin/dashboard-stats`.
    - Displays 4 real-time metric cards: Total Reports, Pending Review, In Progress, and Resolved.
    - Computes and visualizes an operational **Resolution Rate** percentage bar: `Math.round((resolved / total) * 100)`.

### 3.3 Navigation and Routing Table

| URL Route | Component | Access Permission | Functional Purpose |
| :--- | :--- | :--- | :--- |
| `/` | `Home` | Public (redirects if logged in) | Landing page with platform overview |
| `/signup` | `Signup` | Public | Account registration for citizen or admin |
| `/login` | `Login` | Public | Credential verification and session creation |
| `/report` | `Report` | Authenticated (`user` role) | Civic complaint filing form |
| `/my-reports` | `MyReports` | Authenticated (`user` role) | Personal complaint history and tracking |
| `/profile` | `UserProfile` | Authenticated (`user` role) | Citizen account and service area display |
| `/admin-dashboard` | `AdminDashboard` | Authenticated (`admin` role)| Metric overview and performance rates |
| `/all-reports` | `AllReports` | Authenticated (`admin` role)| Regional complaint listing and filtering |
| `/admin/update-status`| `UpdateReportStatus`| Authenticated (`admin` role)| Complaint status modification interface |

### 3.4 Authentication Context (`AuthContext.jsx`)
State is centralized using the React Context API (`createContext`, `useContext`):
- **Synchronous initialization:** Reads `localStorage.getItem("token")` upon mount. If a token exists, it decodes user properties (`id`, `role`, `username`, `state`, `area`) using `jwtDecode(token)`.
- **`login(token)` function:** Saves the token string into browser `localStorage`, updates React state with the decoded token payload, and triggers component re-renders.
- **`logout()` function:** Clears `localStorage.removeItem("token")`, resets `user` and `token` state to `null`.
- **Cross-tab synchronization:** Listens to the `window.addEventListener("storage", ...)` event, automatically logging out or syncing the session if credentials change in another browser tab.

### 3.5 API Communication and Proxying
- Frontend components use the `axios` HTTP library to call relative endpoints starting with `/api` (e.g., `axios.get("/api/user/my-reports")`).
- In local development, **Vite Proxy** (`vite.config.js`) intercepts all requests starting with `/api` and `/uploads` and forwards them to the Express server at `http://localhost:5000`:
  ```javascript
  server: {
    proxy: {
      "/api": { target: "http://localhost:5000", changeOrigin: true, secure: false },
      "/uploads": { target: "http://localhost:5000", changeOrigin: true, secure: false }
    }
  }
  ```
- This configuration prevents browser CORS preflight failures during local development and eliminates the need to hardcode `http://localhost:5000` inside React components.

---

## 4. Backend Analysis

### 4.1 Express Server Initialization (`server.js`)
The backend is an asynchronous **Express 5** application:
1. **Environment Configuration:** Loads configuration using `require("dotenv").config()`. Sets default fallbacks if `.env` variables (`PORT`, `MONGO_URI`, `JWT_SECRET`) are not provided.
2. **CORS Security Middleware:** Configured with a dynamic origin validator that permits deployed Vercel domains (`https://city-care-chi.vercel.app`, `https://jansamasya.vercel.app`) as well as local development hosts (`localhost`, `127.0.0.1` on any port).
3. **Body Parsing Middleware:**
   - `express.json()` parses inbound JSON payloads.
   - `express.urlencoded({ extended: true })` parses standard URL-encoded form data.
4. **Static Assets Route:** Exposes the uploaded photos directory:
   ```javascript
   app.use("/uploads", express.static(path.join(__dirname, "uploads")));
   ```
5. **Route Mounting:**
   - `/api/auth` mounts `authRoutes`
   - `/api/user` mounts `userRoutes`
   - `/api/admin` mounts `adminRoutes`
6. **Global Error Handling Middleware:** Catches unhandled errors across controllers, logs the stack trace to the console, and returns `HTTP 500`: `{"message": "Something went wrong!"}`.
7. **Database Connection & Lifecycle:** Invokes `connectDB()` via Mongoose with `serverSelectionTimeoutMS: 5000` and `family: 4` (enforcing IPv4 to prevent Windows IPv6 DNS resolution delays). If the database is initially offline, it automatically logs an error and retries connection every 5 seconds.

### 4.2 Middleware Suite
- **`authMiddleware.js`:**
  1. `authMiddleware`: Extracts the HTTP `Authorization` request header. Validates that it starts with `Bearer <token>`. Decodes and verifies the token using `jwt.verify(token, process.env.JWT_SECRET)`. Injects the decoded claims payload into `req.user`. If missing or expired, responds with `HTTP 401 Unauthorized`.
  2. `requireRole(role)`: Higher-order authorization function. Checks if `req.user.role === role`. If the authenticated user has a different role (e.g., a citizen attempting to access an administrator route), it rejects the request with `HTTP 403 Forbidden` (`{"message": "Access denied: Insufficient role"}`).
- **`upload.js`:**
  - Configures **Multer** with a disk-storage engine.
  - Automatically creates the `backend/uploads/` directory on disk using `fs.mkdirSync` if it does not already exist.
  - Generates unique filenames: `Date.now() + path.extname(file.originalname)`.
  - Enforces a regex file filter validating file extensions and MIME types: `/jpeg|jpg|png/`. Rejects non-image file uploads with an error.

### 4.3 Controllers Architecture
- **`authController.js`:** Handles `signup` (validates required fields, checks for duplicate email and username, hashes password via bcrypt, creates user, issues JWT) and `login` (checks user existence, verifies role match, compares password via bcrypt, issues JWT).
- **`userController.js`:** Handles `getUserProfile` (returns authenticated user details), `createReport` (constructs image URL from host, writes Report document), `getMyReports` (queries reports where `user === req.user.id` sorted by creation date descending), `updateReport` (allows citizen to edit title/description), and `deleteReport` (removes user's own report).
- **`adminController.js`:** Handles `getAllReports` (filters reports by state and regex area, populates author username/email), `updateReportStatus` (validates status against `pending`, `in-progress`, `resolved`, patches database), `getAdminDashboardStats` (executes four parallel `countDocuments()` queries for metrics), and `deleteAnyReport` (allows administrator to delete abusive reports).

---

## 5. Database Analysis

### 5.1 Active Database vs. Inactive Database
During our local database investigation, two separate databases were detected on the MongoDB server:

```
MongoDB Server (mongodb://127.0.0.1:27017)
│
├── fixmytown  <--- [ACTIVE APPLICATION DATABASE]
│   ├── users    (Citizen and Administrator accounts)
│   └── reports  (Civic issue complaints and image references)
│
└── jansamasya <--- [INACTIVE / UNUSED DATABASE]
    ├── users, departments, complaints, auditlogs, notifications
    (Belongs to a completely separate prototype; NOT referenced anywhere in this codebase)
```

**Crucial Technical Fact:** JanSamasya's backend configuration explicitly connects to `fixmytown`:
- `MONGO_URI=mongodb://127.0.0.1:27017/fixmytown` in `backend/.env`.
- `mongodb://mongodb:27017/fixmytown` in `docker-compose.yml`.

### 5.2 Collections and Schemas

#### 1. `users` Collection (Model: `backend/models/User.js`)
Stores authenticated user records for both citizens and municipal administrators.

```javascript
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true }, 
  email:    { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role:     { type: String, enum: ["user", "admin"], default: "user" },
  state:    { type: String, required: true },
  area:     { type: String },
});
```

- **Validation Rules:** Unique indexes are enforced on both `username` and `email`.
- **Role Control:** Restricted strictly to `"user"` or `"admin"`.
- **Location Tagging:** Every user must specify their state (e.g., `"uttar pradesh"` or `"delhi"`), which binds their municipal jurisdiction.

#### 2. `reports` Collection (Model: `backend/models/Report.js`)
Stores civic grievance records filed by citizens.

```javascript
const reportSchema = new mongoose.Schema(
  {
    title:       { type: String, required: true, trim: true },
    description: { type: String, trim: true },
    category:    { type: String, trim: true, default: "other" },
    imageUrl:    { type: String, default: "" },
    status: {
      type: String,
      enum: ["pending", "in-progress", "resolved"],
      default: "pending",
    },
    user:  { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    state: { type: String, required: true },
    area:  { type: String },
  },
  { timestamps: true }
);
```

- **Timestamps:** `{ timestamps: true }` automatically generates `createdAt` and `updatedAt` ISO date fields.
- **Foreign Key Relation:** `user` stores a `mongoose.Schema.Types.ObjectId` referencing the `User` model, establishing a relational 1-to-Many link (One User has Many Reports).
- **Status Lifecycle:** Strictly enforced by Mongoose enum to three strings: `"pending"`, `"in-progress"`, `"resolved"`.

### 5.3 Entity Relationship (ER) Diagram

```
+---------------------------------------+             +---------------------------------------+
|                 User                  |             |                Report                 |
+---------------------------------------+             +---------------------------------------+
| _id          : ObjectId (PK)          |<-----+      | _id          : ObjectId (PK)          |
| username     : String (Unique)        |      |      | title        : String                 |
| email        : String (Unique)        |      |      | description  : String                 |
| password     : String (Bcrypt Hash)   |      |      | category     : String                 |
| role         : "user" | "admin"       |      +-----O{ user         : ObjectId (FK -> User)  |
| state        : String                 |             | imageUrl     : String                 |
| area         : String                 |             | status       : "pending" | "in-prog" |
+---------------------------------------+             |                "resolved"             |
                                                      | state        : String                 |
                                                      | area         : String                 |
                                                      | createdAt    : ISODate                |
                                                      | updatedAt    : ISODate                |
                                                      +---------------------------------------+
```

---

## 6. Authentication and User Roles

### 6.1 Registration Flow
1. User completes the form on `/signup`.
2. Frontend sends a `POST` request to `/api/auth/signup` containing:
   `{ username, email, password, role, state, area }`.
3. Backend controller checks whether the email or username is already taken.
4. Passwords are encrypted using `bcrypt.hash(password, 10)` producing a 60-character salted hash.
5. The user record is created in MongoDB.
6. A JWT token is signed and returned alongside the sanitized user profile.

### 6.2 Login Flow
1. User submits credentials on `/login`: `{ username, password, role }`.
2. Backend queries the database: `User.findOne({ username })`.
3. If no user is found, returns `HTTP 401: Invalid credentials`.
4. Checks role match: If `user.role !== role`, returns `HTTP 403: Access denied: Incorrect role selected`.
5. Verifies the password using `bcrypt.compare(password, user.password)`. If false, returns `HTTP 401`.
6. Generates a signed JWT token containing the user payload.
7. Frontend decodes the token, saves it to `localStorage`, and updates React context state.

### 6.3 JWT Token Structure
Tokens are generated using `jsonwebtoken` with an expiration period of **1 day** (`{ expiresIn: "1d" }`).

- **Header:** Algorithm (`HS256`), Type (`JWT`).
- **Payload Claims:**
  ```json
  {
    "id": "6739...",
    "role": "user",
    "username": "citizen_rahul",
    "state": "Uttar Pradesh",
    "area": "Gomti Nagar",
    "iat": 1731885600,
    "exp": 1731972000
  }
  ```
- **Signature:** `HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), JWT_SECRET)`

### 6.4 Citizen vs. Administrator Permissions
The system enforces **Role-Based Access Control (RBAC)** across frontend routes and backend APIs:

| Feature / Action | Citizen (`role: "user"`) | Administrator (`role: "admin"`) |
| :--- | :---: | :---: |
| Access Public Landing Page | Yes | Yes |
| File a Civic Issue Report | **Yes** | No |
| View Personal Filed Reports | **Yes** | No |
| Edit/Delete Own Report | **Yes** | No |
| View Regional Overview (All Reports) | No | **Yes** |
| Filter Complaints by District/Area | No | **Yes** |
| Change Report Status (`resolved`, etc.) | No | **Yes** |
| View Municipal KPI Dashboard & Rates | No | **Yes** |
| Delete Any Report in Jurisdiction | No | **Yes** |

### 6.5 How Administrator Access Currently Works
In the current application architecture, **any user can select "Municipal Administrator" from the registration dropdown on `/signup`**.
- There is currently no administrative secret key, invitation token, or manual approval workflow required to create an administrator account.
- Once created with `role: "admin"`, the backend issues a JWT containing `"role": "admin"`, granting access to the `/api/admin/*` routes.
- This design allows easy academic testing and evaluation, but represents a key security consideration for production (see [Section 12](#12-testing-security-observations--limitations)).

---

## 7. Complete Functionality & Feature Classification

### 7.1 Detailed Feature Audit

Every feature in the application has been audited and classified into one of four standard states:
- **Implemented and verified** (Present in source code, fully integrated, and verified working)
- **Implemented but not verified** (Present in source code but not actively tested)
- **Partially implemented** (Backend or frontend code exists but lacks complete end-to-end integration)
- **Not implemented** (Mentioned in comments/documentation, but no code exists)

---

#### 1. User Registration — `Implemented and verified`
- Form located at `frontend/src/pages/Signup.jsx`.
- Validates required inputs, captures geographical location, securely hashes passwords, and creates documents in MongoDB.
- Verified via automated API test (`POST /api/auth/signup` returned `HTTP 201`).

#### 2. User Login — `Implemented and verified`
- Form located at `frontend/src/pages/Login.jsx`.
- Authenticates credentials, checks role consistency, issues JWT, and stores token in browser `localStorage`.
- Verified via automated test (`POST /api/auth/login` returned `HTTP 200` with valid JWT).

#### 3. User Profile Display — `Implemented and verified`
- Page located at `frontend/src/pages/UserProfile.jsx`.
- Fetches profile data from `GET /api/user/profile` using Bearer authentication. Displays account username, email, state, and district area.
- Verified via automated test.

#### 4. Complaint / Report Submission — `Implemented and verified`
- Page located at `frontend/src/pages/Report.jsx`.
- Citizen selects category, enters title and description, and optionally attaches an image.
- Sends multipart payload to `POST /api/user/report`.
- Automatically populates the issue's `state` and `area` based on the citizen's profile.
- Verified via automated test (`POST /api/user/report` returned `HTTP 201` with saved document).

#### 5. Image Upload & Static Hosting — `Implemented and verified`
- Middleware in `backend/middleware/upload.js`.
- Multer processes binary image files, validates extension/mimetype, and saves files to `backend/uploads/`.
- Express serves images statically over `http://localhost:5000/uploads/:filename`.
- Vite proxies `/uploads` to ensure images render cleanly in the frontend.
- Verified via upload test and static URL resolution.

#### 6. Complaint History (Citizen) — `Implemented and verified`
- Page located at `frontend/src/pages/MyReports.jsx`.
- Queries `GET /api/user/my-reports`.
- Displays personal complaints, showing category emoji badges, status indicators, and photo thumbnails.
- Verified via automated test (fetched array of user complaints).

#### 7. Regional Complaint Listing (Administrator) — `Implemented and verified`
- Page located at `frontend/src/pages/AllReports.jsx`.
- Queries `GET /api/admin/reports`.
- Scopes query to the administrator's assigned state and provides real-time area filtering.
- Verified via automated test (fetched populated complaints array).

#### 8. Complaint Status Updates — `Implemented and verified`
- Page located at `frontend/src/pages/UpdateReportStatus.jsx`.
- Submits `PUT /api/admin/report/:id/status` with new status value (`pending`, `in-progress`, or `resolved`).
- Patches the database document and updates status badges.
- Verified via automated test (updated status from `pending` to `in-progress`).

#### 9. Administrator Analytics Dashboard — `Implemented and verified`
- Page located at `frontend/src/pages/AdminDashboard.jsx`.
- Calls `GET /api/admin/dashboard-stats`.
- Fetches real-time counts (`total`, `pending`, `inProgress`, `resolved`) and calculates percentage resolution rate.
- Verified via automated test (returned valid counter object).

#### 10. Complaint Editing & Deletion by Citizen — `Partially implemented`
- Backend endpoints `PUT /api/user/report/:id` and `DELETE /api/user/report/:id` are fully implemented in `userController.js`.
- The frontend `MyReports.jsx` UI currently does not render edit/delete action buttons; backend API exists but is not hooked up to the user interface.

#### 11. Complaint Deletion by Administrator — `Implemented but not verified`
- Backend endpoint `DELETE /api/admin/report/:id` is fully implemented in `adminController.js`.
- Allows administrators to remove invalid or abusive reports.

#### 12. Geographic Filtering (State / Area) — `Implemented and verified`
- Configured in `adminController.js`:
  ```javascript
  let filter = {};
  if (targetState) filter.state = new RegExp(`^${targetState}$`, "i");
  if (area) filter.area = new RegExp(area.trim(), "i");
  ```
- Case-insensitive regex matching ensures flexible searches regardless of casing.

#### 13. GPS Geolocation Auto-Detection — `Not implemented`
- Mentioned in `frontend/README.md` ("📝 Users can submit local issue reports with optional geolocation").
- Currently, location is selected manually via the State dropdown and Area text input. Browser HTML5 Geolocation API (`navigator.geolocation`) is not implemented.

#### 14. Email or SMS Notifications — `Not implemented`
- Mentioned in landing page copy ("Citizens will be notified").
- No SMTP service (such as Nodemailer, SendGrid, or Twilio) is configured in the codebase. All status updates must be viewed directly inside the web portal.

#### 15. Officer Dashboard Role — `Not implemented`
- The active application supports only two roles: `"user"` (Citizen) and `"admin"` (Municipal Administrator). There is no third `"officer"` role in the active `fixmytown` database.

---

## 8. API Documentation

All API endpoints are prefixed with `/api`. Requests to protected endpoints must provide the HTTP header:  
`Authorization: Bearer <JWT_TOKEN>`

| Endpoint | Method | Purpose | Auth Required | Required Role | Controller Handler |
| :--- | :---: | :--- | :---: | :---: | :--- |
| `/api/auth/signup` | `POST` | Register a new user or administrator | No | None (Public) | `authController.signup` |
| `/api/auth/login` | `POST` | Authenticate user and obtain JWT | No | None (Public) | `authController.login` |
| `/api/auth/protected` | `GET` | Healthcheck testing token validity | **Yes** | Any role | Inline middleware handler |
| `/api/user/profile` | `GET` | Retrieve authenticated citizen profile | **Yes** | `user` | `userController.getUserProfile` |
| `/api/user/report` | `POST` | Submit a new civic issue complaint | **Yes** | `user` | `userController.createReport` |
| `/api/user/my-reports`| `GET` | Fetch complaints filed by logged-in user | **Yes** | `user` | `userController.getMyReports` |
| `/api/user/report/:id`| `PUT` | Edit title or description of own complaint | **Yes** | `user` | `userController.updateReport` |
| `/api/user/report/:id`| `DELETE`| Delete personal complaint | **Yes** | `user` | `userController.deleteReport` |
| `/api/admin/reports` | `GET` | List all regional complaints with area filter | **Yes** | `admin` | `adminController.getAllReports` |
| `/api/admin/dashboard-stats` | `GET` | Fetch count metrics (total, pending, etc.) | **Yes** | `admin` | `adminController.getAdminDashboardStats` |
| `/api/admin/report/:id/status`| `PUT` | Update complaint status lifecycle | **Yes** | `admin` | `adminController.updateReportStatus` |
| `/api/admin/report/:id`| `DELETE`| Remove any complaint from database | **Yes** | `admin` | `adminController.deleteAnyReport` |

---

## 9. Complete Step-by-Step Data Flow

```
========================================================================================
                              CITIZEN SUBMISSION FLOW
========================================================================================

[Citizen Browser]                           [Express Server (:5000)]                [MongoDB Database (:27017)]
       |                                                |                                         |
       | 1. Fills form (title, desc, category, photo)   |                                         |
       | 2. Submits multipart/form-data                 |                                         |
       |----------------------------------------------->|                                         |
       |    POST /api/user/report                       |                                         |
       |    Header: Bearer <JWT>                        |                                         |
       |                                                | 3. authMiddleware verifies JWT          |
       |                                                | 4. requireRole checks role === 'user'   |
       |                                                | 5. Multer streams file to disk          |
       |                                                |    (backend/uploads/1731...jpg)         |
       |                                                | 6. Prepares Report document:            |
       |                                                |    - title, description, category       |
       |                                                |    - imageUrl (http://.../uploads/..)   |
       |                                                |    - user: req.user.id                  |
       |                                                |    - state: req.user.state              |
       |                                                |    - area: req.user.area                |
       |                                                | 7. report.save()                        |
       |                                                |---------------------------------------->|
       |                                                |                                         | 8. Inserts into
       |                                                |                                         |    fixmytown.reports
       |                                                |<----------------------------------------|
       |                                                |    Document saved with _id              |
       | 9. HTTP 201 Created                            |                                         |
       |<-----------------------------------------------|                                         |
       |    {"message": "Report submitted", report: {}} |                                         |
       v                                                v                                         v
```

```
========================================================================================
                            ADMINISTRATOR RESOLUTION FLOW
========================================================================================

[Admin Browser]                             [Express Server (:5000)]                [MongoDB Database (:27017)]
       |                                                |                                         |
       | 1. Opens /all-reports or filters by area       |                                         |
       |----------------------------------------------->|                                         |
       |    GET /api/admin/reports?area=Gomti           | 2. authMiddleware & requireRole('admin')|
       |    Header: Bearer <AdminJWT>                   | 3. Queries Report.find({state, area})   |
       |                                                |    .populate("user", "username email")  |
       |                                                |---------------------------------------->|
       |                                                |<----------------------------------------|
       | 4. HTTP 200 with populated reports array       |                                         |
       |<-----------------------------------------------|                                         |
       |                                                |                                         |
       | 5. Selects Report ID and sets status='resolved'|                                         |
       |----------------------------------------------->|                                         |
       |    PUT /api/admin/report/:id/status            | 6. Validates status enum string         |
       |    Body: {"status": "resolved"}                | 7. findByIdAndUpdate(id, {status})      |
       |                                                |---------------------------------------->|
       |                                                |<----------------------------------------|
       | 8. HTTP 200 OK {"message": "Status updated"}   |    Database document updated            |
       |<-----------------------------------------------|                                         |
       v                                                v                                         v
```

---

## 10. File & Media Storage

### 10.1 Physical Storage Mechanism
- JanSamasya uses **local server filesystem storage** for media handling.
- Uploaded files are written directly to disk inside `backend/uploads/`.
- No third-party cloud object storage service (such as AWS S3, Cloudinary, or Google Cloud Storage) is used in this repository.

### 10.2 Storage Process & Path Construction
1. When a citizen submits a photo via `<input type="file" accept="image/*">`, `Multer` intercepts the binary stream.
2. The file is saved on disk with a timestamp-based filename:
   `Date.now() + path.extname(file.originalname)` (e.g., `1773414624461.jpg`).
3. In `userController.js`, the permanent public URL is constructed:
   ```javascript
   const filename = req.file?.filename || "";
   const imageUrl = filename
     ? `${req.protocol}://${req.get("host")}/uploads/${filename}`.replace(/\\/g, "/")
     : "";
   ```
4. This absolute URL (e.g., `http://localhost:5000/uploads/1773414624461.jpg`) is stored as a string inside the `imageUrl` field of the MongoDB `Report` document.
5. In the frontend, `<img src={report.imageUrl} alt="Report evidence" />` displays the uploaded photo directly.

---

## 11. Execution and Deployment Guide

### 11.1 Prerequisites
- **Node.js:** v18, v20, or v24+
- **NPM:** v9, v10, or v11+
- **MongoDB:** Community Server running locally on port `27017`

### 11.2 Required Environment Variable Names (`backend/.env`)

The backend requires the following environment variables (names only; values should be configured privately in your local `.env` file and never committed to public repositories):

| Variable Name | Purpose |
| :--- | :--- |
| `PORT` | TCP port number on which the Express backend listens (default local port: `5000`) |
| `MONGO_URI` | MongoDB connection string pointing to the active `fixmytown` database |
| `JWT_SECRET` | Private cryptographic key used to sign and verify JWT authentication tokens |

*(Note: On Windows systems, using IPv4 loopback `127.0.0.1` inside `MONGO_URI` is recommended over `localhost` to avoid IPv6 DNS timeout delays).*

### 11.3 Step-by-Step Execution Commands

#### 1. Start MongoDB Service
Verify that MongoDB Server is active. In Windows PowerShell:
```powershell
Get-Service -Name MongoDB
# If stopped:
Start-Service -Name MongoDB
```

#### 2. Start Backend API Server
```powershell
cd c:\Users\Calpeda\Music\CityCare-main\backend
npm install
node server.js
```
*Expected Console Output:*
```
Using URI: mongodb://127.0.0.1:27017/fixmytown
Attempting MongoDB connection...
✅ Connected to MongoDB
🚀 Server running on http://localhost:5000
```

#### 3. Start Frontend Client Development Server
Open a second terminal:
```powershell
cd c:\Users\Calpeda\Music\CityCare-main\frontend
npm install
npm run dev
```
*Expected Console Output:*
```
  VITE v6.3.5  ready in 455 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
```

### 11.4 Docker Deployment Configuration
The repository includes a ready-to-run multi-container `docker-compose.yml`:
- **`jansamasya-mongo`:** Runs official MongoDB image on port `27017:27017` with persistent volume `mongo-data`.
- **`jansamasya-backend`:** Builds `backend/Dockerfile` (Node Alpine), binds port `5050:5000`, and links to the MongoDB container.
- **`jansamasya-frontend`:** Builds `frontend/Dockerfile` using a multi-stage Docker build (compiles Vite assets, copies them into an Alpine Nginx image), and serves on port `3000:80`.

To start all services with Docker:
```bash
docker compose up --build
```

---

## 12. Testing, Security Observations & Limitations

### 12.1 Verified Functionality
The following operational capabilities were verified via end-to-end integration tests:
- Citizen signup with duplicate prevention.
- Administrator signup.
- Role-conditional login authentication.
- JWT generation and payload verification.
- Profile retrieval for authenticated citizens.
- Multipart complaint submission with category assignment and image handling.
- Personal report history queries for citizens.
- Admin dashboard KPI counter aggregation.
- Administrative regional complaint browsing and area filtering.
- Complaint lifecycle status transitions (`pending` → `in-progress` → `resolved`).
- Zero ESLint syntax errors.
- Successful React production build generation (`vite build` in 12.05s).

### 12.2 Security Weaknesses & Improvement Recommendations

| Identified Weakness | Impact / Risk | Recommended Mitigation |
| :--- | :--- | :--- |
| **Open Admin Signup** | Any visitor can register as a Municipal Administrator from the public `/signup` dropdown and gain full administrative access. | Remove `"admin"` from public registration; implement an internal invitation key or require admin approval. |
| **Hardcoded Secret Fallback** | If `JWT_SECRET` is omitted from `.env`, the server falls back to a hardcoded default string in `server.js`. | Enforce that the server refuses to start in production if `JWT_SECRET` is undefined. |
| **Unbounded Local File Storage** | Uploaded photos are stored on local disk without size quotas or thumbnail compression. | Integrate cloud object storage (AWS S3, Cloudinary) and add Sharp-based image optimization. |
| **No Password Complexity Policy** | Users can register with short passwords (e.g., 4 characters). | Implement Zxcvbn or regex validation enforcing at least 8 characters with numbers and symbols. |
| **No Rate Limiting** | The login and signup routes lack request rate limiting. | Add `express-rate-limit` to protect auth endpoints against brute-force attacks. |
| **No Audit Logging** | Status modifications do not record which specific administrator performed the change or when. | Create an `AuditLog` collection recording `{ reportId, modifiedBy, previousStatus, newStatus, timestamp }`. |

### 12.3 Academic Presentation Summary (For Project Defense / Viva)

When presenting JanSamasya during an evaluation or project defense, highlight the following core points:
1. **Clear Architectural Separation:** The system strictly separates concerns into presentation (React 19 SPA), business logic (Express 5 REST API), and persistence (MongoDB 7 Mongoose models).
2. **Stateless Authentication:** Uses JSON Web Tokens (JWT) stored in client `localStorage`, eliminating server-side session memory overhead and enabling horizontal scalability.
3. **Relational Mongoose Modeling:** Demonstrates relational data design in NoSQL by referencing `User._id` inside `Report.user` and executing query joins using Mongoose `.populate()`.
4. **Resilient Network Proxying:** Vite's local reverse proxy cleanly avoids CORS issues during development, while Docker Compose and Nginx provide containerized production deployment.
5. **Practical Civic Relevance:** Solves real-world municipal problems through geographic categorization and transparent status tracking.

---
*Document generated for JanSamasya repository analysis. All verified details reflect the actual codebase at `c:\Users\Calpeda\Music\CityCare-main`.*
