# 🚀 Complete Deployment Guide: Plant Identifier Cloud Setup

This guide walks you through deploying the **Plant Identifier** application to free, publicly accessible cloud hosting so that anyone can open and use it from any smartphone, laptop, or computer over the internet **without requiring your laptop to be on or connected**.

---

## Architecture Overview

| Component | Platform | Free Tier Highlights |
| :--- | :--- | :--- |
| **Database** | [Supabase](https://supabase.com) or [Neon](https://neon.tech) | 100% Free PostgreSQL, 500MB storage, instant connection string |
| **Backend API** | [Render](https://render.com) | Free Web Service with automatic HTTPS (`https://plant-identifier-api.onrender.com`) |
| **Frontend Web** | [Vercel](https://vercel.com) or [Render Static](https://render.com) | Free Global CDN, custom domain or `.vercel.app` / `.onrender.com` |
| **Mobile App (Optional APK)** | Standalone Android Build | Connects directly over cellular data to the Render backend |

---

## Step 1: Set Up the Free Remote PostgreSQL Database

You need a remote PostgreSQL database that remains active 24/7. **Supabase** or **Neon** take less than 2 minutes to create:

### Option A: Using Supabase (Recommended)
1. Go to [supabase.com](https://supabase.com) and create a free account (Sign in with GitHub).
2. Click **New Project**.
3. Choose a project name (e.g. `plant-db`), enter a database password (remember this!), and pick the region closest to you (e.g., `Singapore` or `US East`).
4. Click **Create new project** and wait ~1 minute for provisioning.
5. Go to **Project Settings** (gear icon at bottom left) ➔ **Database**.
6. Scroll down to **Connection String** ➔ Select the **Pooler** tab (or **Transaction / Session** mode), **NOT Direct**!
   > **Why Pooler?** Supabase's Direct connection (`db.xxxx.supabase.co:5432`) uses IPv6 only. Cloud platforms like Render only support IPv4 outgoing connections. The Connection Pooler (`aws-0-[region].pooler.supabase.com:6543`) has full IPv4 support.
7. Copy the URI string. It looks like:
   ```text
   postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres
   ```
   *(Replace `[YOUR-PASSWORD]` with the database password you created in step 3).*
   *(For project `ujqtfdlbnsrihmaejmhqm`, it will be: `postgresql://postgres.ujqtfdlbnsrihmaejmhqm:[YOUR-PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres`).*

### Option B: Using Neon
1. Go to [neon.tech](https://neon.tech) and click **Sign Up** (Sign in with GitHub).
2. Create a project named `plant-db`.
3. In your dashboard, copy the **Connection string**:
   ```
   postgresql://user:password@ep-xxxx.us-east-2.aws.neon.tech/neondb?sslmode=require
   ```

Keep this connection string ready; this is your `DATABASE_URL`.

---

## Step 2: Push Your Code to GitHub

If your project is not already on GitHub:
1. Create a new GitHub repository at [github.com/new](https://github.com/new) (e.g. `plant-identifier`).
2. In your VS Code terminal in the project root:
   ```bash
   git add .
   git commit -m "Configure production deployment for cloud hosting"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/plant-identifier.git
   git push -u origin main
   ```

---

## Step 3: Deploy the Backend API to Render.com

Render provides a completely free Web Service for Python / Django:

1. Go to [render.com](https://render.com) and sign up / log in with your GitHub account.
2. From the Render Dashboard, click **New +** ➔ **Web Service**.
3. Select **Build and deploy from a Git repository**, click **Next**, and choose your `plant-identifier` repository.
4. Configure the service settings:
   - **Name**: `plant-identifier-api` (or any unique name you choose)
   - **Region**: Oregon or Singapore (choose what is closest to your database)
   - **Branch**: `main`
   - **Root Directory**: *(leave blank)*
   - **Runtime**: `Python 3`
   - **Build Command**: `./build.sh`
   - **Start Command**: `gunicorn plant.wsgi:application --log-file - --workers 2 --threads 4`
   - **Instance Type**: **Free**
5. Scroll down to **Environment Variables** and click **Add Environment Variable** for each of these:
   | Key | Value | Notes |
   | :--- | :--- | :--- |
   | `DATABASE_URL` | `postgresql://...` | Paste your Supabase or Neon connection string from Step 1 |
   | `PYTHON_VERSION` | `3.11.9` | Ensures stable Linux Python environment on Render |
   | `DEBUG` | `False` | Disables debug mode for production security |
   | `SECRET_KEY` | *(Click "Generate" or paste a random string)* | Django cryptographic key |
   | `ALLOWED_HOSTS` | `.onrender.com,localhost,127.0.0.1` | Allows Render domain |
   | `CORS_ALLOW_ALL_ORIGINS` | `True` | Allows the mobile app and frontend to talk to the API |
6. Click **Create Web Service**.
7. Render will automatically run `./build.sh` (which installs packages, runs `collectstatic`, and runs `python manage.py migrate` to create all tables in your remote PostgreSQL database).
8. Once deployment finishes, Render gives you a public HTTPS URL at the top, for example:
   `https://plant-identifier-api.onrender.com`

### Test Your Live Backend
Open `https://plant-identifier-api.onrender.com` in your browser. You will see:
```text
🌱 Unified Plant Identifier Backend is running!
```

---

## Step 4: Deploy the Frontend (Flutter Web)

You can deploy the Flutter Web frontend to **Vercel** or **Render Static Site**:

### Method A: Deploy via Vercel (Fastest & Easiest)
1. Build the production web bundle with your live Render backend URL:
   ```bash
   flutter build web --release --dart-define=BACKEND_URL=https://plant-identifier-api.onrender.com
   ```
2. Go to [vercel.com](https://vercel.com) and sign in with GitHub.
3. Click **Add New...** ➔ **Project**.
4. Import your GitHub repository `plant-identifier`.
5. In Project Settings:
   - **Framework Preset**: Other
   - **Root Directory**: `./`
   - **Output Directory**: `build/web`
6. Click **Deploy**.
7. Vercel will deploy your application and give you a public URL like:
   `https://plant-identifier.vercel.app`

*(Alternative drag-and-drop: You can also install the Vercel CLI via `npm i -g vercel` and run `vercel deploy --prebuilt` inside `build/web`).*

### Method B: Deploy as Render Static Site
1. On [render.com](https://render.com), click **New +** ➔ **Static Site**.
2. Connect your `plant-identifier` repository.
3. Settings:
   - **Build Command**: `flutter/bin/flutter build web --release --dart-define=BACKEND_URL=https://plant-identifier-api.onrender.com`
   - **Publish Directory**: `build/web`
4. Click **Create Static Site**.

---

## Step 5: (Optional) Build the Standalone Android Mobile App (APK)

If you also want a standalone Android app on your phone that connects directly over cellular data to your public cloud backend:

1. Build the release APK with your live Render URL:
   ```bash
   flutter build apk --release --dart-define=BACKEND_URL=https://plant-identifier-api.onrender.com
   ```
2. The built APK will be saved at:
   `build/app/outputs/flutter-apk/app-release.apk`
3. Send this APK file to your phone (via Google Drive, Telegram, email, or WhatsApp) and install it on your phone.

---

## Step 6: How to Test from Your Phone (Without Laptop)

To verify the app is 100% independent of your laptop:

1. **Disconnect / Close Laptop**:
   - Turn off Wi-Fi on your laptop or close the lid.
2. **On Your Phone**:
   - Turn OFF your phone's Wi-Fi.
   - Turn ON **Mobile Data** (4G / 5G).
3. **Open the Application**:
   - Open your browser (Chrome or Safari) and go to your frontend URL:
     `https://plant-identifier.vercel.app`
4. **Test the Core Features**:
   - **Sign Up / Log In**: Register a new account. Notice how the account is created instantly in your remote Supabase/Neon PostgreSQL database!
   - **Chatbot**: Ask a plant care question in the Chat-Bot tab.
   - **Plant Identifier / Scan**: Tap Scan / Camera, upload or snap a photo of a plant to identify it.
   - **Saved Plants & History**: Save plants to your collection and verify your history updates.

---

## Troubleshooting & Tips

- **Free Tier Cold Starts**: Render's free tier spins down the web service after 15 minutes of inactivity. The first request after inactivity might take 30–50 seconds to wake up. Once awake, subsequent requests respond within milliseconds.
- **Updating Backend URL in Code**: If your deployed domain changes, you can either:
  1. Rebuild with `--dart-define=BACKEND_URL=https://your-new-url.onrender.com`
  2. Or update `defaultProductionBackendUrl` in [`lib/api/api_config.dart`](file:///c:/Users/reali/Desktop/Plant-Identifier/lib/api/api_config.dart).

