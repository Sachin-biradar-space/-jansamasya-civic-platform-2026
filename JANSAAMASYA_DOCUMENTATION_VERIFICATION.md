# JanSamasya – Documentation Verification & Technical Audit Report

> **Target Document Audited:** `JANSAAMASYA_PROJECT_SEGMENTATION.md`  
> **Audit Scope:** Strict read-only line-by-line verification against actual frontend, backend, database, and deployment source files in `c:\Users\Calpeda\Music\CityCare-main`.  
> **Modifications Made to Source Code / Database / Original Report:** None (Read-Only Audit).

---

## Executive Audit Summary

Overall, `JANSAAMASYA_PROJECT_SEGMENTATION.md` captures the high-level MERN architecture, active database (`fixmytown`), models, and core controllers accurately. However, a strict audit against the actual source code revealed **20 concrete discrepancies**, including **inaccurate feature verification claims**, **missing route documentation**, **overstated real-time and RBAC claims**, **static/hardcoded UI elements described as dynamic**, **inaccurate Docker/file descriptions**, and **undocumented bugs** in the existing code.

| Audit Area | Verification Verdict | Key Discrepancy Count |
| :--- | :--- | :---: |
| 1. Documented Features vs. Source Code | **Partially Accurate** | 5 discrepancies |
| 2. API Endpoints (12 Documented vs. Actual) | **Incomplete** | 1 undocumented route alias (`13` actual routes) |
| 3. Real-Time Updates Claim | **Inaccurate** | No WebSockets/SSE/polling exist |
| 4. UserProfile Verification Status & Fields | **Inaccurate** | Hardcoded static badge; `email` & `createdAt` never returned |
| 5. MongoDB Schema Fields vs. Models | **Mostly Accurate** | 1 minor ER diagram typo; missing `timestamps` note on `User` |
| 6. Database Connection & Collections | **Mostly Accurate** | MongoDB version mismatch (`v7+` vs actual `8.2.3`) |
| 7. Auth & Admin Authorization Flow | **Inaccurate on Frontend RBAC** | No frontend route guards; admin broken redirect on `/` |
| 8. Image Upload & Storage | **Overstated Verification** | Binary file upload not actually tested; Nginx lacks `/uploads/` proxy |
| 9. Docker Ports & Execution Commands | **Partially Accurate** | Ports accurate; base image (`Node Alpine`) & PowerShell `npm` notes inaccurate |
| 10. Other Contradictions & Unsupported Claims | **Multiple Found** | `vercel.json`, CORS catch-all, sequential vs parallel queries, regex bug |

---

## Section-by-Section Verification Results

### 1. Documented Features vs. Actual Implementation

| Documented Feature | Doc Status | Audited Actual Status | Audit Notes |
| :--- | :--- | :--- | :--- |
| User Registration | Implemented and verified | **Implemented and verified** | Matches `Signup.jsx` & `authController.signup`. Note: Frontend ignores the returned JWT from signup and redirects to `/login`. |
| User Login | Implemented and verified | **Implemented and verified** | Matches `Login.jsx` & `authController.login`. |
| User Profile Display | Implemented and verified | **Partially accurate in doc** | Works for `user` role only; does **not** display `email` or `createdAt` because `getUserProfile` only reads JWT claims. |
| Complaint / Report Submission | Implemented and verified | **Implemented and verified** | Matches `Report.jsx` & `userController.createReport`. |
| Image Upload & Static Hosting | Implemented and verified | **Implemented but not verified** | Multer & static route exist in code, but automated tests only sent text `FormData` fields without attaching a binary image file. |
| Complaint History (Citizen) | Implemented and verified | **Implemented and verified** | Matches `MyReports.jsx` & `userController.getMyReports`. |
| Regional Complaint Listing (Admin) | Implemented and verified | **Implemented and verified** | Matches `AllReports.jsx` & `adminController.getAllReports` (state-scoped). |
| Complaint Status Updates | Implemented and verified | **Implemented and verified** | Matches `UpdateReportStatus.jsx` & `adminController.updateReportStatus`. Only `pending -> in-progress` was tested (not `resolved`). |
| Admin Analytics Dashboard | Implemented and verified | **Implemented and verified (non-real-time)** | Counts are global across all states (not scoped to admin's state) and fetched once on mount, not real-time. |
| Citizen Edit & Delete Report | Partially implemented | **Partially implemented** | Accurate: backend routes exist, no UI buttons in `MyReports.jsx`. |
| Admin Delete Report | Implemented but not verified | **Implemented but not verified** | Accurate: backend route exists (`DELETE /api/admin/report/:id`), no UI button in `AllReports.jsx`. |
| Geographic Filtering (State/Area) | Implemented and verified | **State verified / Area `?area=` not verified** | State filtering was verified; `?area=` query parameter was not tested end-to-end. |
| GPS Geolocation Auto-Detection | Not implemented | **Not implemented** | Accurate. |
| Email or SMS Notifications | Not implemented | **Not implemented** | Accurate. |
| Officer Dashboard Role | Not implemented | **Not implemented** | Accurate (only exists in separate unused `jansamasya` DB). |

---

### 2. Verification of All API Endpoints Against Route Files

Verified against `backend/server.js` (lines 37–39), `backend/routes/authRoutes.js`, `backend/routes/userRoutes.js`, and `backend/routes/adminRoutes.js`:

| # | Route File | Full Mounted Endpoint | HTTP Method | Middleware | Controller | In Doc Table? |
| :-: | :--- | :--- | :---: | :--- | :--- | :---: |
| 1 | `authRoutes.js:6` | `/api/auth/signup` | `POST` | None | `authController.signup` | Yes |
| 2 | `authRoutes.js:7` | `/api/auth/login` | `POST` | None | `authController.login` | Yes |
| 3 | `authRoutes.js:9` | `/api/auth/protected` | `GET` | `authMiddleware` | Inline handler | Yes |
| 4 | `userRoutes.js:13` | `/api/user/profile` | `GET` | `authMiddleware`, `requireRole("user")` | `userController.getUserProfile` | Yes |
| 5 | `userRoutes.js:15` | `/api/user/report` | `POST` | `authMiddleware`, `requireRole("user")`, `upload.single("image")` | `userController.createReport` | Yes |
| 6 | `userRoutes.js:23` | `/api/user/my-reports` | `GET` | `authMiddleware`, `requireRole("user")` | `userController.getMyReports` | Yes |
| 7 | `userRoutes.js:24` | `/api/user/report/:id` | `PUT` | `authMiddleware`, `requireRole("user")` | `userController.updateReport` | Yes |
| 8 | `userRoutes.js:25` | `/api/user/report/:id` | `DELETE` | `authMiddleware`, `requireRole("user")` | `userController.deleteReport` | Yes |
| 9 | `adminRoutes.js:11` | `/api/admin/reports` | `GET` | `authMiddleware`, `requireRole("admin")` | `adminController.getAllReports` | Yes |
| 10 | `adminRoutes.js:13` | `/api/admin/dashboard-stats` | `GET` | `authMiddleware`, `requireRole("admin")` | `adminController.getAdminDashboardStats` | Yes |
| 11 | `adminRoutes.js:20` | `/api/admin/admin/dashboard-stats` | `GET` | `authMiddleware`, `requireRole("admin")` | `adminController.getAdminDashboardStats` | **NO (Missing)** |
| 12 | `adminRoutes.js:27` | `/api/admin/report/:id/status` | `PUT` | `authMiddleware`, `requireRole("admin")` | `adminController.updateReportStatus` | Yes |
| 13 | `adminRoutes.js:34` | `/api/admin/report/:id` | `DELETE` | `authMiddleware`, `requireRole("admin")` | `adminController.deleteAnyReport` | Yes |

**Finding:** All 12 documented endpoints exist and match their methods, auth middleware, roles, and controllers. However, **a 13th route exists** (`GET /api/admin/admin/dashboard-stats` in `backend/routes/adminRoutes.js` lines 20–25) as a backward-compatibility alias and is omitted from Section 8.

---

### 3. Real-Time Updates Verification

**Verdict: NOT real-time.** All data updates use standard request-response REST API calls:
- **No real-time transport exists** in `package.json` (no `socket.io`, `ws`, SSE, or polling timers).
- `MyReports.jsx` (lines 24–43) fetches reports once when mounted (`useEffect` depending on `token`). Status changes made by an admin will **not** appear until the citizen manually refreshes or re-navigates to the page.
- `AdminDashboard.jsx` (lines 24–39) fetches stats once when mounted (`useEffect` depending on `token`). Its "System Health" indicators (`ONLINE`, `CONNECTED`, `SECURED`) are hardcoded static JSX (lines 301–338), and "Last Updated" (line 344) simply renders `new Date().toLocaleTimeString(...)` at component render time.
- `AllReports.jsx` (lines 26–48) triggers a new HTTP `GET /api/admin/reports` request on every keystroke in the area search input (without debouncing), which is on-demand HTTP fetching rather than server-pushed real-time updates.

---

### 4. UserProfile Verification Status & Displayed Fields Verification

Verified against `backend/controllers/userController.js` (lines 3–14) and `frontend/src/pages/UserProfile.jsx` (lines 139–232):
- **Verification Status:** **100% static hardcoded UI content.** Lines 218–232 of `UserProfile.jsx` unconditionally render `"Account Verified — Your account is authenticated and active"` for any loaded profile. There is no `isVerified` field in `User.js` and no email/OTP/account verification backend logic.
- **Email & Member Since (`createdAt`):** `UserProfile.jsx` checks `{profile.email && ...}` (line 153) and `{profile.createdAt && ...}` (line 197), **but neither is ever rendered.** `userController.getUserProfile` only returns `{ id, username, role, state, area }` directly from `req.user` (the decoded JWT payload), without querying MongoDB. Furthermore, `authController.generateToken` does not include `email`, and `User.js` does not enable `{ timestamps: true }`, so `createdAt` does not exist on user documents at all.

---

### 5. MongoDB Schema Fields vs. Actual Models

Verified against `backend/models/User.js` and `backend/models/Report.js`:
- **`User.js`:** Exact match (`username`, `email`, `password`, `role` with `enum: ["user", "admin"]` and `default: "user"`, `state`, `area`; no `timestamps: true`).
- **`Report.js`:** Exact match (`title`, `description`, `category` with `default: "other"`, `imageUrl` with `default: ""`, `status` with `enum: ["pending", "in-progress", "resolved"]` and `default: "pending"`, `user` referencing `"User"`, `state`, `area`, plus `{ timestamps: true }`).
- **Minor Error in ER Diagram:** Line 378 of the report abbreviates `"in-progress"` as `"in-prog"`.

---

### 6. Database Connection and Collection Names Verification

Verified against `backend/server.js`, `backend/.env`, `docker-compose.yml`, and live read-only MongoDB inspection:
- **Active Database:** `fixmytown` — **Verified Accurate.**
- **Active Collections:** `users` and `reports` — **Verified Accurate.**
- **Unused Local Database:** `jansamasya` (`departments`, `notifications`, `users`, `auditlogs`, `complaints`) — **Verified Accurate.**
- **Connection Options:** `serverSelectionTimeoutMS: 5000`, `family: 4`, 5-second retry loop — **Verified Accurate.**
- **Version Discrepancy:** Report lists `MongoDB v7+` / `MongoDB 7`; actual local MongoDB instance is **`8.2.3`**, and Docker uses unpinned `image: mongo`.

---

### 7. Authentication & Administrator Authorization Flow Verification

Verified against `backend/controllers/authController.js`, `backend/middleware/authMiddleware.js`, `frontend/src/App.jsx`, `frontend/src/context/AuthContext.jsx`, `frontend/src/pages/Home.jsx`, `frontend/src/pages/Login.jsx`, and `frontend/src/pages/Signup.jsx`:
- **Backend Authentication & RBAC:** Accurately documented (`bcryptjs` 10 rounds, JWT 1-day expiry, `authMiddleware`, `requireRole("user" | "admin")`).
- **Open Admin Signup:** Accurately documented (`Signup.jsx` allows selecting `"admin"` publicly).
- **Frontend RBAC Claim is Inaccurate:** `App.jsx` has **zero protected route wrappers**. Any unauthenticated user or wrong-role user can directly navigate to `/admin-dashboard`, `/all-reports`, `/admin/update-status`, `/report`, `/my-reports`, or `/profile` (API calls fail with 401/403, but the page component still mounts).
- **Admin Landing Page Bug:** `Home.jsx` (lines 27–30) redirects **all** authenticated users (including `admin`) to `/profile`, which immediately calls `GET /api/user/profile` (restricted to `role: "user"`), producing a `403 Forbidden` error screen for admins.
- **Admin Jurisdiction Scope:** `getAllReports` filters by `req.user.state`, **but** `getAdminDashboardStats`, `updateReportStatus`, and `deleteAnyReport` do **not** check `req.user.state` — they operate globally across all states.
- **No Client-Side Expiration Check:** `AuthContext.jsx` decodes `localStorage` tokens without checking the `exp` claim.

---

### 8. Image Upload & Storage Verification

Verified against `backend/middleware/upload.js`, `backend/controllers/userController.js`, `backend/server.js`, `frontend/vite.config.js`, `frontend/nginx.conf`, and `frontend/src/pages/Report.jsx`:
- **Local Disk Storage (`backend/uploads/`):** Accurately documented; no cloud storage is used.
- **Filename Pattern & URL Construction:** Accurately documented (`Date.now() + ext`, stored as full URL `${req.protocol}://${req.get("host")}/uploads/${filename}`).
- **Verification Claim Overstated:** No actual binary `.jpg`/`.png` file upload was executed in the automated tests; only multipart text fields were tested.
- **Missing Size Limit:** `Report.jsx` displays `"PNG, JPG, JPEG (Max 10MB)"`, but `upload.js` defines no `limits.fileSize` in Multer.
- **Docker/Nginx Missing `/uploads/` Proxy:** `frontend/nginx.conf` proxies `/api/` to `backend:5000`, but does **not** proxy `/uploads/`, which breaks image loading in Docker Compose deployments when `imageUrl` points to the Nginx host.

---

### 9. Documented Docker Ports & Execution Commands Verification

Verified against `docker-compose.yml`, `backend/Dockerfile`, `frontend/Dockerfile`, `backend/package.json`, and `frontend/package.json`:
- **Docker Ports:** `27017:27017` (MongoDB), `5050:5000` (Backend), `3000:80` (Frontend) — **All Accurate.**
- **Localhost Ports:** `27017` (MongoDB), `5000` (Backend), `5173` (Frontend) — **All Accurate.**
- **Docker Base Image Error:** `backend/Dockerfile` uses `FROM node:18` (Debian), **not** Node Alpine. `frontend/Dockerfile` build stage also uses `FROM node:18 AS build`; only the final Nginx stage uses `FROM nginx:alpine`.
- **PowerShell Command Issue:** On Windows PowerShell with restricted script execution policy (observed on this host), `npm install` and `npm run dev` fail unless invoked as `npm.cmd install` and `npm.cmd run dev` (or run via `cmd.exe`).

---

## Detailed Discrepancy Log (Existing Statement vs. Actual Code vs. Correction)

### Discrepancy 1 — Real-Time Updates Claim
- **Existing statement in Markdown report:**
  - Line 29: *"update complaint lifecycles in real time."*
  - Line 222: *"Displays 4 real-time metric cards: Total Reports, Pending Review, In Progress, and Resolved."*
  - Line 500: *"provides real-time area filtering."*
  - Line 512: *"Fetches real-time counts (`total`, `pending`, `inProgress`, `resolved`)"*
- **Actual implementation in source code:**
  - No WebSockets, Server-Sent Events, or polling intervals exist anywhere in `frontend/` or `backend/`.
  - `AdminDashboard.jsx` (lines 24–39) and `MyReports.jsx` (lines 24–43) execute one-time `axios.get` requests on component mount.
  - `AllReports.jsx` (lines 26–48) triggers a standard `axios.get` request whenever `filterArea` changes.
- **Suggested documentation correction:**
  - Replace *"in real time"* and *"real-time"* with *"on demand via standard REST API requests"* (e.g., *"fetches up-to-date counts from MongoDB on page load"* and *"re-queries the API as the administrator types in the area filter"*).

### Discrepancy 2 — UserProfile Email, `createdAt`, and Verification Status
- **Existing statement in Markdown report:**
  - Line 219: *"Displays authenticated citizen details: username, email, state, district/area, role privileges, and verification status."*
  - Line 474: *"Displays account username, email, state, and district area."*
- **Actual implementation in source code:**
  - `backend/controllers/userController.js` (lines 3–14) returns only `{ id, username, role, state, area }` from `req.user` (JWT claims); it never queries MongoDB and never returns `email` or `createdAt`.
  - `frontend/src/pages/UserProfile.jsx` lines 218–232 display a **hardcoded static** `"Account Verified"` card with no backend verification field or logic.
- **Suggested documentation correction:**
  - Clarify that `UserProfile.jsx` displays `username`, `role`, `state`, and `area` sourced from the JWT claims; note that `email` and `createdAt` blocks in JSX never render because the backend does not return them, and that the `"Account Verified"` badge is static UI copy rather than a real verification state.

### Discrepancy 3 — Missing 13th Route Alias in API Table
- **Existing statement in Markdown report:**
  - Section 8 (lines 550–563) lists 12 API endpoints and omits `/api/admin/admin/dashboard-stats`.
- **Actual implementation in source code:**
  - `backend/routes/adminRoutes.js` (lines 20–25) mounts an additional backward-compatibility alias: `GET /api/admin/admin/dashboard-stats` -> `adminController.getAdminDashboardStats`.
- **Suggested documentation correction:**
  - Add `/api/admin/admin/dashboard-stats` (`GET`, Auth Required: Yes, Role: `admin`, Controller: `adminController.getAdminDashboardStats`) to the API table with a note indicating it is a legacy compatibility alias for `/api/admin/dashboard-stats`.

### Discrepancy 4 — Frontend Route-Level RBAC Overstated
- **Existing statement in Markdown report:**
  - Lines 227–237: Routing table lists `Access Permission` as `Authenticated (user role)` or `Authenticated (admin role)` for each route.
  - Line 428: *"The system enforces Role-Based Access Control (RBAC) across frontend routes and backend APIs"*
- **Actual implementation in source code:**
  - `frontend/src/App.jsx` (lines 19–29) renders all 9 routes openly with **no `<ProtectedRoute>` wrapper or role guard**.
  - Only `Navbar.jsx` hides links conditionally, while actual RBAC enforcement happens exclusively on the backend via `authMiddleware` and `requireRole`.
- **Suggested documentation correction:**
  - State clearly that RBAC is strictly enforced on the **backend APIs**, while the frontend only hides navigation links in `Navbar.jsx` and does not currently wrap `<Route>` elements in route guards.

### Discrepancy 5 — Landing Page Access & Admin Redirect Conflict
- **Existing statement in Markdown report:**
  - Line 194: *"Public view. If an authenticated user lands here, it automatically redirects them to `/profile`."*
  - Line 432: *"Access Public Landing Page | Citizen: Yes | Administrator: Yes"*
- **Actual implementation in source code:**
  - `frontend/src/pages/Home.jsx` (lines 27–30): `if (user) { return <Navigate to="/profile" replace />; }`.
  - Authenticated users (both citizens and admins) cannot view `/`; worse, admins redirected to `/profile` trigger `GET /api/user/profile`, which fails with `HTTP 403 Forbidden` because `userRoutes.js:13` requires `role === "user"`.
- **Suggested documentation correction:**
  - Update the permissions table to show that `/` is accessible only when logged out, and document the known bug where logged-in administrators navigating to `/` are redirected to `/profile` and receive a `403` error.

### Discrepancy 6 — Image Upload Marked "Implemented and Verified" Without Binary Upload Test
- **Existing statement in Markdown report:**
  - Line 484–490: *"Image Upload & Static Hosting — `Implemented and verified` ... Verified via upload test and static URL resolution."*
  - Line 736: *"Multipart complaint submission with category assignment and image handling."*
- **Actual implementation in source code / test history:**
  - Multer disk upload (`backend/middleware/upload.js`) and static hosting (`backend/server.js:35`) are implemented, **but** the automated tests only submitted text fields in `FormData` without attaching an actual `.jpg`/`.png` file or requesting an uploaded file over HTTP.
- **Suggested documentation correction:**
  - Reclassify Image Upload & Static Hosting as **`Implemented but not verified`** (or explicitly note that multipart text submission was verified while binary image upload and retrieval remain untested).

### Discrepancy 7 — `getAdminDashboardStats` Described as "Parallel" Instead of Sequential
- **Existing statement in Markdown report:**
  - Line 294: *"getAdminDashboardStats (executes four parallel `countDocuments()` queries for metrics)"*
- **Actual implementation in source code:**
  - `backend/controllers/adminController.js` (lines 57–60) executes four sequential `await Report.countDocuments(...)` calls (not `Promise.all`).
- **Suggested documentation correction:**
  - Change *"four parallel `countDocuments()` queries"* to *"four sequential `countDocuments()` queries"*.

### Discrepancy 8 — Admin Dashboard Stats & Delete/Update Scope Described as "Jurisdictional"
- **Existing statement in Markdown report:**
  - Line 440: *"Delete Any Report in Jurisdiction"*
  - Line 36: *"Regional administrators lack consolidated metrics"*
- **Actual implementation in source code:**
  - Only `getAllReports` (`adminController.js:8–11`) scopes queries by `req.user.state`.
  - `getAdminDashboardStats` (lines 57–60) counts reports **globally across all states**.
  - `updateReportStatus` (lines 37–41) and `deleteAnyReport` (line 72) look up reports strictly by `req.params.id` with **no state/jurisdiction ownership check**.
- **Suggested documentation correction:**
  - Explicitly note that only `GET /api/admin/reports` enforces state-level filtering, whereas dashboard stats, status updates, and admin deletions operate globally across the database.

### Discrepancy 9 — CORS Dynamic Origin Validator Actually Allows All Origins
- **Existing statement in Markdown report:**
  - Line 266: *"Configured with a dynamic origin validator that permits deployed Vercel domains (`https://city-care-chi.vercel.app`, `https://jansamasya.vercel.app`) as well as local development hosts (`localhost`, `127.0.0.1` on any port)."*
- **Actual implementation in source code:**
  - `backend/server.js` (lines 17–32) checks those origins (plus `https://jansamasya-chi.vercel.app`), **but line 29 falls through to `return callback(null, true);`**, effectively permitting **all origins** rather than rejecting unrecognized domains.
- **Suggested documentation correction:**
  - Document that `server.js` currently allows all origins via the fallback `callback(null, true)` on line 29, include `https://jansamasya-chi.vercel.app`, and list the overly permissive CORS fallback under Section 12.2 Security Weaknesses.

### Discrepancy 10 — `backend/Dockerfile` Described as "Node Alpine"
- **Existing statement in Markdown report:**
  - Line 717: *"`jansamasya-backend`: Builds `backend/Dockerfile` (Node Alpine), binds port `5050:5000`"*
- **Actual implementation in source code:**
  - `backend/Dockerfile` line 1 is `FROM node:18` (standard Debian-based Node 18 image, **not** Alpine).
  - Similarly, `frontend/Dockerfile` line 2 uses `FROM node:18 AS build`, and only line 11 uses `FROM nginx:alpine`.
- **Suggested documentation correction:**
  - Change `(Node Alpine)` to `(Node 18 Debian base image: FROM node:18)`.

### Discrepancy 11 — `frontend/vercel.json` Described as Containing Rewrite Rules
- **Existing statement in Markdown report:**
  - Line 147: *"`vercel.json # Optional Vercel deployment rewrite rules`"*
- **Actual implementation in source code:**
  - `frontend/vercel.json` is completely empty (`0 bytes`).
- **Suggested documentation correction:**
  - Describe `vercel.json` as an *"Empty placeholder file (0 bytes; no Vercel deployment rules configured)"*.

### Discrepancy 12 — `frontend/nginx.conf` Missing `/uploads/` Reverse Proxy
- **Existing statement in Markdown report:**
  - Line 83: *"Reverse Proxy `/api` & `/uploads`"* (in architecture diagram covering both Vite and Nginx).
- **Actual implementation in source code:**
  - `frontend/vite.config.js` proxies both `/api` and `/uploads`, **but** `frontend/nginx.conf` (lines 10–17) only proxies `location /api/` and has **no `location /uploads/` block**.
- **Suggested documentation correction:**
  - Clarify that `/uploads` proxying is configured only in Vite (`vite.config.js`) for local development, and is missing from `frontend/nginx.conf` for Docker deployments.

### Discrepancy 13 — `getAllReports` Populated Fields Incomplete in Doc
- **Existing statement in Markdown report:**
  - Line 294: *"populates author username/email"*
  - Line 614: *`.populate("user", "username email")`*
- **Actual implementation in source code:**
  - `backend/controllers/adminController.js` line 19: `.populate("user", "username email state area")`.
- **Suggested documentation correction:**
  - Update both references to include all four populated fields: `"username email state area"`.

### Discrepancy 14 — Status Transitions Verification Scope Overstated
- **Existing statement in Markdown report:**
  - Line 740: *"Complaint lifecycle status transitions (`pending` → `in-progress` → `resolved`)."*
- **Actual implementation / test history:**
  - Automated integration tests only executed `pending` → `in-progress` (`PUT /api/admin/report/:id/status` with `{ status: "in-progress" }`); the transition to `"resolved"` was not explicitly tested.
- **Suggested documentation correction:**
  - State accurately: *"Verified status update (`pending` → `in-progress`); `"resolved"` is supported by the backend enum and UI radio options."*

### Discrepancy 15 — `?area=` Query Filtering Marked Verified Without Test
- **Existing statement in Markdown report:**
  - Line 523: *"Geographic Filtering (State / Area) — `Implemented and verified`"*
  - Line 739: *"Administrative regional complaint browsing and area filtering."*
- **Actual implementation / test history:**
  - `GET /api/admin/reports` was tested without a `?area=` query string. State filtering was exercised, while area regex filtering was not tested end-to-end.
  - Additionally, `adminController.js` line 14 passes raw user input into `new RegExp(area.trim(), "i")` without escaping regex metacharacters (characters like `(` or `[` will throw an exception and return HTTP 500).
- **Suggested documentation correction:**
  - Distinguish state-scoped listing (verified) from `?area=` regex filtering (implemented, not verified), and note the unescaped `RegExp` input limitation under Section 12.

### Discrepancy 16 — Static Hardcoded UI Elements Not Flagged
- **Existing statement in Markdown report:**
  - Line 195: *"Displays promotional banners, initiative statistics..."*
  - Line 220–223: Describes `AdminDashboard.jsx` analytics and health without noting static elements.
- **Actual implementation in source code:**
  - `AdminDashboard.jsx` (lines 296–352) displays hardcoded static "System Health" indicators (`ONLINE`, `CONNECTED`, `SECURED`).
  - `Home.jsx` (lines 94–140) and `Report.jsx` (lines 325–341) display hardcoded mock numbers (`12,547` reports, `9,832` resolved, `45,231` users, `78%` rate) not pulled from MongoDB.
  - `Navbar.jsx` (lines 134–148) renders a mobile hamburger button with no `onClick` handler or menu drawer.
  - `Home.jsx` (line 87) renders a `"View Live Issues"` button with no `onClick` handler.
- **Suggested documentation correction:**
  - Document these hardcoded metrics and non-wired UI controls under Section 12 as known limitations so they are not mistakenly presented as live database-driven features during a viva.

### Discrepancy 17 — `index.css` Description Inaccurate
- **Existing statement in Markdown report:**
  - Line 154: *"`index.css # Global styles with Tailwind directives and custom button classes`"*
- **Actual implementation in source code:**
  - `frontend/src/index.css` defines `.nav-link` and `.mobile-link` classes (not button classes), and neither class is referenced anywhere in the frontend JSX files.
- **Suggested documentation correction:**
  - Update description to: *"Global stylesheet importing Tailwind directives (`@tailwind base/components/utilities`) plus two unused helper classes (`.nav-link`, `.mobile-link`)."*

### Discrepancy 18 — ER Diagram Status Enum Typo
- **Existing statement in Markdown report:**
  - Line 378: `status : "pending" | "in-prog" | "resolved"`
- **Actual implementation in source code:**
  - `backend/models/Report.js` line 11: `enum: ["pending", "in-progress", "resolved"]`.
- **Suggested documentation correction:**
  - Correct `"in-prog"` to `"in-progress"` in the ER diagram.

### Discrepancy 19 — Version Contradictions (Node.js & MongoDB)
- **Existing statement in Markdown report:**
  - Line 56: `Node.js | v20+ / v24+` vs. Line 660: `Node.js: v18, v20, or v24+`.
  - Line 58: `MongoDB (Community Server) | v7+` and Line 758: `MongoDB 7 Mongoose models`.
- **Actual implementation / environment:**
  - Dockerfiles use `node:18`; host machine runs `Node v24.20.0` and `MongoDB 8.2.3`.
- **Suggested documentation correction:**
  - Standardize Node.js to `v18+ (Docker uses Node 18; tested locally on v24.20.0)` and MongoDB to `MongoDB Community Server (tested locally on v8.2.3; Docker uses official mongo image)`.

### Discrepancy 20 — Windows PowerShell `npm` Execution Note & Client Validation Gaps
- **Existing statement in Markdown report:**
  - Lines 688, 703–704: Provides `npm install` and `npm run dev` in Windows PowerShell blocks without mentioning script execution policy restrictions.
  - Section 3 does not note missing validation enforcement on `Report.jsx`.
- **Actual implementation / environment:**
  - On Windows PowerShell with script execution disabled, `npm` fails with `PSSecurityException`; `npm.cmd install` and `npm.cmd run dev` are required.
  - `Report.jsx` displays `"Minimum 20 characters"` (line 164) and `"Max 10MB"` (line 190), neither of which is enforced in HTML attributes or Multer `limits`.
  - `Home.jsx` (lines 190–191) and `UpdateReportStatus.jsx` (lines 156, 170, 175, 262–273) use dynamically interpolated Tailwind classes (`bg-${color}-50`, `text-${color}-600`, etc.) without a `safelist` in `tailwind.config.js`, meaning those styles are purged during `vite build`.
- **Suggested documentation correction:**
  - Add a Windows PowerShell tip to use `npm.cmd` (or Command Prompt) if script execution is restricted, and list the un-enforced 20-char/10MB limits and dynamic Tailwind class purging as known limitations in Section 12.

---

## Summary Checklist of Verification Items

| # | Requested Audit Check | Result |
| :-: | :--- | :--- |
| 1 | Every documented feature vs. actual code | Verified; 3 overstatements (`Image Upload`, `Area Filtering`, `Resolved` transition) and several undocumented UI stubs identified |
| 2 | All 12 API endpoints vs. route files | All 12 exist and match; **1 additional alias route** (`/api/admin/admin/dashboard-stats`) found in `adminRoutes.js` |
| 3 | Real-time updates vs. normal API calls | **Normal HTTP REST API calls only**; no WebSockets, SSE, or polling |
| 4 | `UserProfile` verification status | **Hardcoded static UI**; `email` and `createdAt` are also never returned by the backend |
| 5 | MongoDB schema fields vs. models | Models match accurately; minor `"in-prog"` typo in ER diagram |
| 6 | Database connection & collection names | Active `fixmytown` (`users`, `reports`) and unused `jansamasya` accurately documented; MongoDB version is `8.2.3` (not 7) |
| 7 | Auth & admin authorization flow | Backend RBAC accurate; **frontend has no route guards**, admin redirect on `/` causes `403`, and admin stats/update/delete are global rather than state-scoped |
| 8 | Image upload & storage | Local disk (`backend/uploads/`) accurate; binary upload not actually tested; no Multer size limit; `nginx.conf` lacks `/uploads/` proxy |
| 9 | Docker ports & execution commands | Ports (`27017`, `5050:5000`, `3000:80`) accurate; `backend/Dockerfile` is `node:18` (not Alpine); PowerShell requires `npm.cmd` when scripts are restricted |
| 10 | Inaccurate / contradictory / unsupported statements | 20 total discrepancies logged above with exact locations and corrections |

---
*End of Read-Only Verification Report.*
