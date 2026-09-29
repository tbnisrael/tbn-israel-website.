# TBN Israel Programs & Support

Responsive website scaffold: public homepage, contact form, Bitcoin donation information, gift-card enquiry guidance, and a private administrator inbox.

## Deploy
Upload the **contents** of this folder to the root of `tbnisrael/tbn-israel-website` (not only the ZIP). Ensure `index.html`, `admin.html`, `styles.css`, and `config.js` are at repository root, and retain the `supabase` folder. Vercel: Root Directory `./`, Framework Preset `Other`, Build Command empty. Commit changes; Vercel should redeploy. The public homepage is `/`; admin is `/admin.html`.

## Enable messaging
1. Create a Supabase project.
2. Run `supabase/schema.sql` in Supabase SQL Editor.
3. Create the owner's user in Supabase Authentication.
4. Find that user's UUID in Authentication → Users and run:
   `insert into public.admin_users(user_id) values ('PASTE-USER-UUID');`
5. Put the Supabase Project URL and anon/public key in `config.js`. These are browser-safe only when RLS is enabled. Never put service-role keys, database passwords, or payment secrets in browser code.
6. Commit `config.js` and other files, then test the public form and admin sign-in. Only UUIDs added to `admin_users` can read messages and reply. Add CAPTCHA/rate limiting and test access controls before broad public launch.

## Donations and production
The site displays this Bitcoin address: `bc1q0ypafa2gun9mcndkzqhu95p5kqk6juq5gmh4wd`. Verify it is yours and test the receiving process before publishing. Gift cards are enquiry-only; confirm brands and safe handling separately, and never collect gift card codes in public forms. Card payments are not active; use a hosted checkout or server-side endpoint, verify provider webhooks, and keep secret keys server-side. Add real contact, privacy, legal and donation disclosures before launch.

This is a frontend/database scaffold, not a configured live backend or payment processor. Supabase credentials, admin authorisation, testing, and payment integration remain to be completed by the site owner. The hero image is remotely hosted; replace it with properly licensed artwork if needed.
