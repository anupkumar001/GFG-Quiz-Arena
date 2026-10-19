GFG QUIZ ARENA — ONLINE DEPLOYMENT STARTER
===========================================

What is included
- Responsive quiz home page
- Student details form (name, department, year)
- Owner sign-in
- Owner dashboard to create/publish quizzes
- Question builder with 2–26 options and a per-question timer (5–600 seconds)
- Results table for the owner
- Footer text: "Site Build by Anup Kumar"
- Supabase database security policies

IMPORTANT SECURITY NOTE
This is a deployment starter, not yet production-secure grading. The current client app reads correct_option_index along with public quiz questions and computes the score in the browser. A technically skilled student could inspect the browser/API and potentially discover answers or alter a submitted score. Before using this for a high-stakes or competitive event, move question answer keys and score calculation to a Supabase Edge Function/server-side endpoint. For a normal demo/practice quiz, use it only after you understand this limitation.

STEP 1 — Create Supabase project
1. Open https://supabase.com and create a project.
2. In Project Settings > API, copy the Project URL and anon/public key.
3. Open app.js and replace:
   SUPABASE_URL = "PASTE_YOUR_SUPABASE_PROJECT_URL_HERE"
   SUPABASE_ANON_KEY = "PASTE_YOUR_SUPABASE_ANON_KEY_HERE"
   The anon/public key is intended for browser apps when Row Level Security is enabled. NEVER put a service_role key in this website.

STEP 2 — Create tables and policies
1. In Supabase, open SQL Editor.
2. Paste and run the complete supabase-schema.sql file.
3. Open Authentication > Users and create your owner user with your email and a strong password.
4. Copy the owner user's UUID.
5. In SQL Editor run (replace the example UUID):
   insert into public.owner_accounts (user_id) values ('YOUR-OWNER-USER-UUID');
6. Keep the owner password private. Do not share it with students.

STEP 3 — Deploy the website
Option A: Netlify (simple static hosting)
1. Open https://www.netlify.com and create/sign in to your account.
2. Drag the GFG_Quiz_Arena folder into Netlify's manual deploy area, or connect the GitHub repository.
3. Once deployed, open the site URL and test it.

Option B: GitHub Pages
GitHub Pages can host the static front end, but Netlify is easier for first-time setup and custom domain options.

STEP 4 — Test before sharing
1. Open the public website in a private/incognito browser window.
2. Confirm the student can see published quizzes but cannot see the owner dashboard.
3. Sign in using Owner Login.
4. Create a quiz, add questions, publish it.
5. Test the quiz as a student and check results in the owner dashboard.

Database notes
- The SQL script enables Row Level Security and uses owner_accounts to authorize quiz management.
- Public visitors can read published quizzes/questions and submit attempts; they cannot manage quizzes/questions or read other students' attempts.
- The current version allows up to 26 options per question because a standard alphabetic option label is used.
- Per-question timer limits are 5 to 600 seconds.
- For a real competition, add server-side validation, rate limiting, and server-side grading before announcing the site as secure.

Files
- index.html       Main site
- style.css        Responsive visual design
- app.js           Site behavior and Supabase integration
- supabase-schema.sql  Database schema and row-level security policies
- README.txt       Setup guide
