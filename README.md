# Student Study Progress Dashboard

An academic-planning prototype for CUHK-Shenzhen students and academic advisors. The system combines an API-backed SIS course catalogue with cohort-specific Study Headway calculation, school competency exploration, career-oriented skill/course recommendations, GPA visualization, and an Academic Advisor dashboard.

## Links

- [Deployed student interface](https://b6b40bd4.student-dashboard.pages.dev/students-interface/login)
- [Render API](https://student-dashboard-demo.onrender.com)
- [GitHub repository](https://github.com/re-stellaris/Student-dashboard-demo)
- [Latest release](https://github.com/re-stellaris/Student-dashboard-demo/releases/latest)

## Start Here

| If you want to… | Start with |
|---|---|
| Understand the student dashboard | [`students-interface/student_dashboard_index.html`](students-interface/student_dashboard_index.html) |
| Edit the login experience | [`frontend/src/App.jsx`](frontend/src/App.jsx) and [`students-interface/login.html`](students-interface/login.html) |
| Work on the Academic Advisor dashboard | [`aa_dashboard_v2.html`](aa_dashboard_v2.html) |
| Inspect or extend the API | [`api_server.py`](api_server.py) |
| Rebuild the MySQL schema | [`course_db_api_tables.sql`](course_db_api_tables.sql) |
| Import SIS courses into MySQL | [`tools/import_sis_courses.py`](tools/import_sis_courses.py) |
| Re-run the SIS crawler/export workflow | [`tools/sis-crawler/`](tools/sis-crawler/) |
| Review the course database | [`course_list_database/sis_course_outlines_export.xlsx`](course_list_database/sis_course_outlines_export.xlsx) |
| Rebuild the competency panel data | [`tools/build_competency_data.py`](tools/build_competency_data.py) |
| Inspect competency-analysis outputs | [`competency-analysis/`](competency-analysis/) |
| Rebuild career recommendation data | [`job-hunting-module/`](job-hunting-module/) and [`tools/build_intern_prep_data.py`](tools/build_intern_prep_data.py) |
| Review or extend Study Headway rules | [`graduation_rules/`](graduation_rules/) and [the extraction skill](.agents/skills/extract-graduation-rules/SKILL.md) |
| Change deployment routing | [`wrangler.jsonc`](wrangler.jsonc) and [`_redirects`](_redirects) |

## Repository Map

```text
Student-dashboard-demo/
├── frontend/                       React/Vite login frontend
│   ├── src/App.jsx
│   ├── src/main.jsx
│   └── vite.config.js
├── students-interface/             Student-facing static pages and generated data
│   ├── login.html
│   ├── student_dashboard_index.html
│   ├── course_detail.html
│   ├── ge_area_b.html
│   ├── ge_area_c.html
│   ├── ge_area_d.html
│   ├── competency_data.js          Generated; do not edit manually
│   └── intern_prep_data.js         Generated; do not edit manually
├── aa_dashboard_v2.html            Academic Advisor interface
├── api_server.py                   FastAPI application
├── course_db_api_tables.sql        MySQL schema and demonstration records
├── course_list_database/           SIS catalogue and outline workbooks
├── tools/                          Import, generation, and crawling utilities
├── competency-analysis/            Competency sources, scripts, evidence, and workbooks
├── job-hunting-module/             JD-to-skill-to-course pipeline
├── graduation_rules/               Human-readable SDS rules and cohort index
├── .agents/skills/                 Reusable AI-assisted analysis workflows
├── docs/                            Project workflow notes
├── wrangler.jsonc                  Cloudflare asset configuration
└── _redirects                      Frontend and API routing rules
```

## Main Data Flows

### Course database

```text
SIS catalogue and outline pages
  → tools/sis-crawler/
  → course_list_database/sis_course_outlines_export.xlsx
  → tools/import_sis_courses.py
  → MySQL courses table
  → FastAPI /api/courses
  → course browser and detail pages
```

Key files:

- [`tools/sis-crawler/sis_outline_crawler.mjs`](tools/sis-crawler/sis_outline_crawler.mjs): authorized SIS collection workflow.
- [`tools/sis-crawler/export_sis_outlines_to_excel.py`](tools/sis-crawler/export_sis_outlines_to_excel.py): exports collected records.
- [`course_list_database/Course_List_byInitial.xlsx`](course_list_database/Course_List_byInitial.xlsx): multilingual title supplement.
- [`tools/import_sis_courses.py`](tools/import_sis_courses.py): imports all records and flags courses with valid outlines.
- [`api_server.py`](api_server.py): exposes course list and detail endpoints.

The workbook contains 3,358 course records; 1,727 have saved outline information. Missing-outline records remain available for transcript recognition but are hidden from the student-facing course browser.

### School competency panel

```text
Programme study schemes + SIS course outlines
  → competency-analysis workflow
  → competency-analysis/a_to_z_course_competency_relevance.xlsx
  → tools/build_competency_data.py
  → students-interface/competency_data.js
  → School Competency Pool
```

Navigation:

- [`competency-analysis/major_competency_identifier.skill`](competency-analysis/major_competency_identifier.skill): original major-competency analysis workflow.
- [`competency-analysis/major_competency_ai_review.xlsx`](competency-analysis/major_competency_ai_review.xlsx): reviewed major competency output.
- [`competency-analysis/a_to_z_course_competency_relevance.xlsx`](competency-analysis/a_to_z_course_competency_relevance.xlsx): final school pools and course relevance results.
- [`tools/build_competency_data.py`](tools/build_competency_data.py): browser-data generator.

### Career-oriented recommendations

```text
Career keywords
  → public Shixiseng job descriptions
  → trainable professional skills
  → high-recall SIS course candidates
  → AI semantic review
  → job-hunting-module/releases/
  → students-interface/intern_prep_data.js
  → Prepare for Your Intern panel
```

The complete navigation, counts, methodology, and reproduction steps are in [`job-hunting-module/README.md`](job-hunting-module/README.md). Important entry points include:

- [`job-hunting-module/config/keywords.txt`](job-hunting-module/config/keywords.txt): 437 career search keywords.
- [`job-hunting-module/src/crawl/crawl_shixiseng.py`](job-hunting-module/src/crawl/crawl_shixiseng.py): resumable JD crawler.
- [`job-hunting-module/src/skill_extraction/build_skill_mapping.py`](job-hunting-module/src/skill_extraction/build_skill_mapping.py): professional-skill extraction.
- [`job-hunting-module/src/course_matching/match_courses.py`](job-hunting-module/src/course_matching/match_courses.py): high-recall course retrieval.
- [`job-hunting-module/skills/evaluate-course-skill-fit/SKILL.md`](job-hunting-module/skills/evaluate-course-skill-fit/SKILL.md): evidence-based semantic review.
- [`job-hunting-module/releases/`](job-hunting-module/releases/): publishable summary workbooks.

### Cohort-specific Study Headway

```text
Programme study schemes by admission year
  → AI-assisted rule interpretation
  → human review
  → programmed cohort rules
  → transcript/portfolio matching
  → Study Headway panel
```

Navigation:

- [`.agents/skills/extract-graduation-rules/SKILL.md`](.agents/skills/extract-graduation-rules/SKILL.md): reusable interpretation workflow.
- [`.agents/skills/extract-graduation-rules/references/rule-interpretation-framework.md`](.agents/skills/extract-graduation-rules/references/rule-interpretation-framework.md): rule semantics and review framework.
- [`graduation_rules/SDS_major_rules_summary.md`](graduation_rules/SDS_major_rules_summary.md): human-checkable SDS rule notes.
- [`graduation_rules/SDS_major_rules_index.json`](graduation_rules/SDS_major_rules_index.json): available programme/cohort variants.
- [`docs/study-progress-workflow.md`](docs/study-progress-workflow.md): concise end-to-end workflow.

Detailed major-progress calculation is currently validated primarily for SDS programmes. Credit transfers, exchanges, exemptions, and individually approved substitutions may require manual input.

## Run Locally

### Requirements

- Node.js 18+
- Python 3.10+
- MySQL 8+

### Install and build

```bash
npm install
pip install fastapi "uvicorn[standard]" mysql-connector-python openpyxl
npm run frontend:build
```

Create a MySQL database and load the schema:

```bash
mysql -u root -p -e "CREATE DATABASE course_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p course_db < course_db_api_tables.sql
```

Import the SIS workbook:

```bash
python tools/import_sis_courses.py --workbook course_list_database/sis_course_outlines_export.xlsx
```

Configure the database connection with `MYSQL_URL` or these environment variables:

```text
DB_HOST=localhost
DB_PORT=3306
DB_NAME=course_db
DB_USER=root
DB_PASSWORD=your_password
DB_SSL_DISABLED=true
```

Start the backend:

```bash
python api_server.py
```

Open `http://localhost:8080/students-interface/student_dashboard_index.html`.

For React/Vite development:

```bash
npm run frontend:dev
```

Vite runs on `http://localhost:5173` and proxies `/api` to `http://127.0.0.1:8080`.

## Deployment Navigation

- [`wrangler.jsonc`](wrangler.jsonc): Cloudflare asset directory and SPA fallback.
- [`_redirects`](_redirects): production routes and Render API proxy.
- [`frontend/vite.config.js`](frontend/vite.config.js): frontend build and local proxy settings.
- [`netlify.toml`](netlify.toml): retained alternative/static hosting configuration.
- [`tools/prepare_netlify_publish.mjs`](tools/prepare_netlify_publish.mjs): assembles static pages into the Vite build output.

The deployed frontend uses Cloudflare Pages and routes course API requests to the Render-hosted FastAPI service. MySQL credentials are supplied through deployment environment variables and must never be committed.

## Generated Files and Source of Truth

| Generated file | Rebuild from |
|---|---|
| [`students-interface/competency_data.js`](students-interface/competency_data.js) | [`competency-analysis/a_to_z_course_competency_relevance.xlsx`](competency-analysis/a_to_z_course_competency_relevance.xlsx) via [`tools/build_competency_data.py`](tools/build_competency_data.py) |
| [`students-interface/intern_prep_data.js`](students-interface/intern_prep_data.js) | [`job-hunting-module/releases/`](job-hunting-module/releases/) via [`tools/build_intern_prep_data.py`](tools/build_intern_prep_data.py) |
| SIS database `courses` table | [`course_list_database/sis_course_outlines_export.xlsx`](course_list_database/sis_course_outlines_export.xlsx) via [`tools/import_sis_courses.py`](tools/import_sis_courses.py) |

Edit the source workbook or generation script, then regenerate the output. Do not manually maintain large generated JavaScript datasets.

## Scope and Data Safety

- The login and browser session are prototypes, not official university SSO.
- The dashboard is an academic-planning prototype, not an official graduation audit or employment guarantee.
- Competency and course-recommendation results are evidence-based analytical outputs and still require human review.
- Do not commit passwords, API keys, production credentials, real student records, full raw JD corpora, private SIS exports, or local scratch files.
- SIS crawling must be performed only by authorized users and in accordance with university policies.

For module-specific limitations, see [`job-hunting-module/docs/limitations.md`](job-hunting-module/docs/limitations.md) and the notes linked from each workflow above.
