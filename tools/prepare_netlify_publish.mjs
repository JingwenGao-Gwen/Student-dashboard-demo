import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';

const distDir = join('frontend', 'dist');
const dashboardPath = '/students-interface/student_dashboard_index.html';

function copyIfExists(from, to) {
  if (!existsSync(from)) return;
  mkdirSync(dirname(to), { recursive: true });
  copyFileSync(from, to);
}

cpSync('students-interface', join(distDir, 'students-interface'), { recursive: true });
copyFileSync(
  join('students-interface', 'student_dashboard_index.html'),
  join(distDir, 'student_dashboard.html'),
);
copyIfExists('aa_dashboard.html', join(distDir, 'aa_dashboard.html'));
copyIfExists(join('assets', 'favicon.svg'), join(distDir, 'assets', 'favicon.svg'));

// Copy aa_dashboard_v2.html
copyIfExists('aa_dashboard_v2.html', join(distDir, 'aa_dashboard_v2.html'));

writeFileSync(
  join(distDir, 'index.html'),
  `<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="refresh" content="0; url=${dashboardPath}" />
    <title>Study Dashboard</title>
    <script>location.replace('${dashboardPath}');</script>
  </head>
  <body>
    <p>Redirecting to <a href="${dashboardPath}">Study Dashboard</a>...</p>
  </body>
</html>
`,
);

// ── Cloudflare Pages _redirects ──────────────────────────────────────
writeFileSync(
  join(distDir, '_redirects'),
  `# Cloudflare Pages redirects
/                           /students-interface/student_dashboard_index.html  302
/index.html                 /students-interface/student_dashboard_index.html  302
/aa_dashboard.html          /aa_dashboard.html                                200
/aa_dashboard               /aa_dashboard.html                                200
/aa_dashboard_v2.html       /aa_dashboard_v2.html                             200
/aa_dashboard_v2            /aa_dashboard_v2.html                             200
/student_dashboard.html     /student_dashboard.html                           200
/students-interface/*       /students-interface/:splat                        200
/api/*                      https://student-dashboard-demo.onrender.com/api/:splat  200
/*                          /index.html                                       200
`,
);

// ── Cloudflare Pages _headers ────────────────────────────────────────
writeFileSync(
  join(distDir, '_headers'),
  `# Cloudflare Pages headers
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin

/assets/*
  Cache-Control: public, max-age=31536000, immutable
`,
);
