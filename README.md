# Student Study Progress Dashboard

The Student Study Progress Dashboard is an academic planning and competency-visualization platform developed for AIE 4902 AI Capstone Project II. It is intended to help students understand their academic progress, explore course options, and connect course selection with professional competency development. It also provides academic advisors with a consolidated view of advisee progress and risk indicators.

This midterm implementation extends a predecessor prototype by strengthening its course-data foundation, redesigning its competency-analysis workflow, improving course navigation and user interaction, and refining the GPA trajectory and skill-matrix interfaces.

## Midterm Improvements

### 1. Course catalogue and course-outline expansion

An AI-assisted Playwright crawler was developed to collect SIS course-catalogue and course-outline information. The workflow extracts structured fields including:

- course code, title, school, academic organization, units, and grading basis;
- English and Chinese descriptions;
- prerequisites and co-requisites;
- learning outcomes and course syllabus;
- assessment scheme, grade type, and course components; and
- offered terms and source information.

The previous course file contained approximately 408 records. The expanded dataset contains 3,358 course records across 106 subjects, including 1,727 courses with valid outline information. Courses without complete outlines are retained separately so that missing-data limitations remain visible.

The crawler and export scripts are located in [`tools/sis-crawler/`](tools/sis-crawler/). The resulting SIS workbook is stored at [`course_list_database/sis_course_outlines_export.xlsx`](course_list_database/sis_course_outlines_export.xlsx).

### 2. AI-assisted competency analysis

The previous skill categories and course-skill matrix elements were largely designed manually. To support campus-wide expansion, the revised workflow separates competency analysis into two stages.

First, `major_competency_identifier.skill` analyzes programme study schemes and identifies curriculum-supported competencies.
Second, major-level competencies are consolidated into school-level competency pools. Courses with valid outlines are evaluated against the competency pool associated with their offering school. The analysis uses course descriptions, learning outcomes, syllabi, assessment information, title signals, course-code signals, and matched outline evidence.

The final analysis contains:

- 1,591 scored courses;
- 13,907 course-competency relevance records; and
- 135 UCore or rule-based excluded courses.

The score represents relevance between a course and a competency area. It does not measure course quality, difficulty, workload, credit weight, or career value.

The skill, scripts, evidence files, study-scheme sources, and final workbooks are stored in [`competency-analysis/`](competency-analysis/).

### 3. Course navigation and detail information

The Available Course panel loads course records from the FastAPI `/api/courses` endpoint. Course IDs link directly to detail pages that display SIS catalogue and outline fields, including descriptions, prerequisites, learning outcomes, syllabus, assessment information, school, academic organization, grading basis, offered terms, and outline availability.

This design keeps the student-facing course information aligned with the expanded SIS workbook instead of the inherited static `data.js` catalogue.

The previous skill matrix and skill-driven recommendation UI are currently disabled because their inherited score model is not aligned with the latest competency-analysis workbook. The competency display will be redesigned after the new A-Z competency result format is finalized.

### 4. Dashboard interaction and user experience

The updated prototype includes nickname input, automatic avatar generation, direct course navigation, and course-level comments. Users can post comments on course detail pages and delete comments they created, providing a lightweight personalization and peer-feedback layer.

These functions are prototypes rather than a production identity or social system. Official SSO integration, persistent account management, moderation, authorization, and security hardening remain outside the current midterm scope.

### 5. GPA trajectory and Study Headway prototype

The GPA trajectory's vertical axis was changed from 0-4.0 to 2.0-4.0, reducing unnecessary blank space and making performance changes easier to interpret. The skill matrix was reorganized according to each course's major category and simplified to reduce irrelevant columns and visual clutter.

The dashboard also includes an initial Study Headway panel. It reads the student's transcript and manually added exemption or approved courses, updates progress when the selected course list changes, and presents credit, UCore, and major progress in the student dashboard.

Detailed major-progress analysis is currently implemented only for SDS programmes. The SDS prototype compares completed courses with saved study-scheme rules by admission year and major, including required courses, selective groups, elective areas, and completed/to-take marking. Other schools are intentionally deferred because they still need validated reference cases; keeping them out of the detailed rule engine controls validation effort and token/development cost for this stage.

## System Architecture

```text
Student / Academic Advisor
            |
            v
React login interface + HTML/JavaScript dashboards
            |
            v
FastAPI application (api_server.py)
            |
            v
MySQL course, student, enrolment, GPA, and advising tables

Supporting analytical data flow:

Registry study schemes ---> Major competency identification
SIS course pages ---------> Course catalogue and outline crawler
                               |
                               v
                    School-level competency pools
                               |
                               v
                    Course-competency relevance results

SDS study schemes --------> Graduation-rule notes
UCore curriculum docs ----> Study Headway progress checks
```

The deployed frontend is configured through `netlify.toml`. API requests are redirected to the separately hosted FastAPI service. The local FastAPI application also serves the built frontend and static dashboard pages.

## Repository Structure

```text
Student-dashboard-demo/
|-- README.md
|-- .gitignore
|-- package.json
|-- package-lock.json
|-- api_server.py
|-- course_db_api_tables.sql
|-- netlify.toml
|-- aa_dashboard.html
|-- login.html
|-- frontend/
|   |-- index.html
|   |-- vite.config.js
|   `-- src/
|       |-- App.jsx
|       |-- main.jsx
|       `-- styles.css
|-- students-interface/
|   |-- index.html
|   |-- login.html
|   |-- guide.html
|   |-- student_dashboard_index.html
|   |-- course_detail.html
|   |-- ge_area_b.html
|   |-- ge_area_c.html
|   |-- ge_area_d.html
|   `-- data.js (legacy static catalogue, not used by the API-backed student interface)
|-- assets/
|-- dataset/
|-- course_list_database/
|   |-- All_Course_Lists.xlsx
|   |-- Course_List_byInitial.xlsx
|   `-- sis_course_outlines_export.xlsx
|-- graduation_rules/
|   |-- SDS_major_rules_summary.md
|   `-- SDS_major_rules_index.json
|-- tools/
|   |-- import_sis_courses.py
|   |-- download_registry_study_schemes.py
|   |-- extract_graduation_rules.py
|   `-- sis-crawler/
|       |-- sis_outline_crawler.mjs
|       |-- export_sis_outlines_to_excel.py
|       |-- package.json
|       `-- package-lock.json
`-- competency-analysis/
    |-- major_competency_identifier.skill
    |-- major_competency_ai_review.xlsx
    |-- a_to_z_course_competency_relevance.xlsx
    |-- scripts/
    |-- evidence/
    `-- source/
```

Generated dependencies and build artefacts such as `node_modules/`, `frontend/dist/`, Python cache files, and `.DS_Store` files are excluded from version control.

## Technology Stack

- **Frontend:** React, Vite, HTML, CSS, and JavaScript
- **Backend:** Python and FastAPI
- **Database:** MySQL
- **Data processing:** Python, JavaScript, Excel, JSON, CSV, and SQL
- **Crawler:** Node.js and Playwright
- **Deployment:** Netlify frontend configuration and separately hosted FastAPI API

## Prerequisites

- Node.js 18 or later
- npm
- Python 3.10 or later
- MySQL 8 or later

## Local Setup

Clone the repository:

```bash
git clone https://github.com/re-stellaris/Student-dashboard-demo.git
cd Student-dashboard-demo
```

Install the dashboard frontend dependencies:

```bash
npm install
```

Install the backend dependencies:

```bash
pip install fastapi "uvicorn[standard]" mysql-connector-python openpyxl
```

Create the local database and import the provided schema and demonstration data:

```bash
mysql -u root -p -e "CREATE DATABASE course_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
cmd /c "mysql -u root -p course_db < course_db_api_tables.sql"
```

Import the expanded SIS course catalogue and outline workbook into the `courses` table. By default, this imports the `All Courses` sheet so transcript matching can recognize ghost/missing-outline courses, while the student-facing browser still hides courses without saved outlines:

```bash
python tools/import_sis_courses.py --workbook course_list_database/sis_course_outlines_export.xlsx
```

During import, `tools/import_sis_courses.py` also reads `course_list_database/Course_List_byInitial.xlsx` to fill `title_en`, `title_zh_cn`, and `title_zh_tw` for language-aware course display.

The student-facing course browser reads courses from the FastAPI `/api/courses` endpoints. It no longer uses `students-interface/data.js` as a course source. Courses with `has_outline = 0` remain available for transcript matching but are not shown in the left course-search panel or detail pages.

Configure the database connection through environment variables:

```text
DB_HOST=localhost
DB_PORT=3306
DB_NAME=course_db
DB_USER=root
DB_PASSWORD=your_password
DB_SSL_DISABLED=true
```

Do not commit database passwords, API keys, or other private credentials.

Build the React frontend:

```bash
npm run frontend:build
```

Start the FastAPI application:

```bash
python api_server.py
```

Open:

```text
http://localhost:8080/app
```

For frontend development:

```bash
npm run frontend:dev
```

The Vite development server runs at `http://localhost:5173` and proxies API requests to `http://127.0.0.1:8080`.

## SIS Crawler

Install the crawler dependency from its own directory:

```bash
cd tools/sis-crawler
npm install
```

Run one letter at a time:

```bash
node sis_outline_crawler.mjs --letters A
```

The crawler opens a browser and requires the authorized user to log into SIS manually. It then navigates through the course catalogue, extracts course details and outlines, and saves structured local outputs. Interrupted runs can be resumed with the crawler's `--from` option.

Export the collected records to Excel:

```bash
python export_sis_outlines_to_excel.py
```

SIS access must only be used by authorized users and in accordance with university policies.

## Data Deliverables

### SIS course-outline workbook

[`course_list_database/sis_course_outlines_export.xlsx`](course_list_database/sis_course_outlines_export.xlsx) contains:

- `All Courses`: all 3,358 collected records and the default import source;
- `With Outline`: courses with available outline information, shown in the student-facing course catalogue; and
- `Missing Outline`: 1,631 courses without complete outline information.

### Major competency workbook

[`competency-analysis/major_competency_ai_review.xlsx`](competency-analysis/major_competency_ai_review.xlsx) summarizes professional competencies inferred from programme study schemes and records the curriculum evidence supporting each interpretation.

### Course-competency workbook

[`competency-analysis/a_to_z_course_competency_relevance.xlsx`](competency-analysis/a_to_z_course_competency_relevance.xlsx) contains detailed course-competency relevance records, course summaries, competency pools, excluded courses, and method notes.

### SDS graduation-rule notes

[`graduation_rules/SDS_major_rules_summary.md`](graduation_rules/SDS_major_rules_summary.md) and [`graduation_rules/SDS_major_rules_index.json`](graduation_rules/SDS_major_rules_index.json) store the current SDS-only major-progress rules extracted from the collected study-scheme materials. These files are used as the reference layer for the Study Headway prototype.

## Success Criteria and Current Evidence

| Criterion | Midterm evidence |
|---|---|
| Expand course coverage beyond the original prototype | Increased from approximately 408 to 3,358 course records |
| Preserve detailed course-outline information | 1,727 courses with valid outlines and structured fields |
| Replace one universal skill list with discipline-aware competency pools | Major competency analysis and school-level competency pools |
| Produce reusable course-competency results | 1,591 scored courses and 13,907 relevance records |
| Improve course-planning interpretability | Course-detail navigation and competency sub-attribute display |
| Improve visualization clarity | Revised 2.0-4.0 GPA scale and major-specific skill-matrix presentation |
| Add initial graduation-progress support | Study Headway prototype with credit, UCore, and SDS major-progress checks |
| Provide verifiable implementation evidence | Source code, datasets, workbooks, screenshots, and video demonstration |

## Demonstration Evidence

The complete midterm video evidence package is available through the [latest GitHub Release](https://github.com/re-stellaris/Student-dashboard-demo/releases/latest).

The package includes:

- a demonstration of the newly implemented dashboard functions; and
- a demonstration of the database and data-analysis workflow.

## Known Limitations and Risks

- The current login interface is a prototype and is not official CUHK-Shenzhen SSO.
- The expanded SIS course dataset is integrated through MySQL and FastAPI. The latest competency-analysis dataset is not yet displayed in the student-facing UI; the inherited skill matrix is disabled until a revised presentation is designed.
- The revised GPA trajectory still uses a unified 2.0-4.0 scale. A future version should adjust the scale according to each student's GPA variance and distribution while retaining suitable visual margins.
- Study Headway currently provides detailed major-progress analysis for SDS only. Non-SDS schools remain outside the detailed rule engine until additional programme-specific reference cases are collected and checked.
- Competency relevance is an AI-assisted analytical result and requires argue access while user discover any mistake during usage.
- SIS page changes may require maintenance of crawler selectors and navigation logic.

## Plan Toward Final Delivery

The next development stage will:

- continue refining the API-backed SIS course database and connect the finalized competency-analysis results to the student-facing UI;
- extend the SDS Study Headway prototype to additional schools after collecting validated reference cases for their study schemes;
- build an initial career-oriented module that connects major-related employment skills with university courses and open online learning resources;
- add AI-assisted summaries of course comments if development time permits; and
- design a reusable AI skill that adapts the course-crawling workflow to other universities and data formats.

Database integration and the SDS Study Headway prototype are the first implemented priorities. The team will then aim to broaden graduation-progress coverage and complete an initial career-oriented recommendation function, while comment summarization will depend on the remaining development time.

## Team Contributions

| Team member | Primary contribution | Main deliverables |
|---|---|---|
| **Gao Jingwen** | Course catalogue expansion and AI-assisted competency evaluation | SIS crawler and export workflow, expanded course database, major competency skill, school-level competency pools, course-competency analysis, repository evidence, and report documentation |
| **Qu Yicheng** | Dashboard analysis, implementation, and repository organization | Review of inherited code, GPA and skill-matrix UI improvements, login and profile personalization, course navigation and comments, repository setup, and report revision |

Git commit history and the submitted report provide additional evidence of individual contributions.

## AI and Tool-Use Disclosure

AI-assisted tools were used for:

- designing and debugging the SIS crawling workflow;
- structuring and cleaning collected course information;
- interpreting study schemes and drafting major competency profiles;
- supporting course-competency relevance analysis;
- assisting with implementation, documentation, and debugging; and
- reviewing repository structure and reproducibility.

Adopted AI outputs were reviewed against programme study schemes, SIS course outlines, structured datasets, generated workbooks, executed code, and interface evidence. The team remains responsible for the correctness, security, interpretation, and originality of all submitted work.

Important AI-related limitations include incomplete source records, possible over-interpretation of curriculum evidence, dependence on prompt and rule design, and the need for human validation of competency results.

## Data and Privacy

The repository is intended to contain demonstration data and academic course information used for the prototype. Passwords, API keys, production credentials, confidential institutional records, and real personal data must not be committed.

## Repository

<https://github.com/re-stellaris/Student-dashboard-demo>
