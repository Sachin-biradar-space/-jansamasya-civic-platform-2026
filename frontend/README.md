🏙️ JanSamasya – A Civic Issue Reporting and Tracking Platform
JanSamasya is a full-stack web application that empowers local citizens to report and track civic issues in their neighborhoods, such as potholes, streetlight outages, and sanitation problems. It also provides admins with a region-specific dashboard to view and address reports within their assigned areas.

🔧 Tech Stack
Frontend: React.js, Tailwind CSS, Lucide Icons

Backend: Node.js, Express.js

Database: MongoDB (with Mongoose ORM)

Authentication: JWT-based login/signup (with role-based access: User/Admin)

Geographic Filtering: Reports and user accounts include state and optional area fields for filtering

REST API: Modular and secure Express-based routes for users, admins, and reports

Deployment: (Optional – add Netlify/Vercel for frontend, Render/Railway for backend)

✨ Features
📝 Users can submit local issue reports (with optional images and geolocation).

👤 Admins can view and filter reports by assigned state and area.

🔐 Role-based login system: Admins and Users have separate dashboards.

📍 Geo-tagged filtering: Ensures admins only access reports relevant to their assigned region.

📊 Dashboard views for My Reports, All Reports (admin), and issue analytics (planned).

📁 Clean folder structure using React Router, controllers, and modular APIs.

📌 Future Improvements
📷 Image upload for reports (via Cloudinary or Firebase Storage)

📊 Issue analytics & status tracking

📩 Admin-user communication (e.g., updates on issue resolution)

🔔 Notifications via email or in-app
