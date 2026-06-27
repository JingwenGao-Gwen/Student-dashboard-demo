# Student Study Progress Dashboard

The Student Study Progress Dashboard is an academic planning and competency-visualization platform developed for AIE 4902 AI Capstone Project II. It is intended to help students understand their academic progress, explore course options, and connect course selection with professional competency development. It also provides academic advisors with a consolidated view of advisee progress and risk indicators.

This midterm implementation extends a predecessor prototype by strengthening its course-data foundation, redesigning its competency-analysis workflow, improving course navigation, and adding a more complete user-interaction flow.

## Project Motivation

Students currently obtain academic information from multiple disconnected sources, including transcripts, SIS course pages, programme study schemes, and university notices. The predecessor dashboard demonstrated the value of integrating this information, but several limitations reduced its reliability and usability:

- The built-in course list covered only a small portion of the campus course pool, so transcript courses missing from the internal database could not be mapped correctly.
- Course exemptions, credit transfers, exchange courses, and approved substitutions were not fully represented by automatic transcript parsing.
- A fixed GPA axis compressed small but meaningful changes in semester performance.
- The skill matrix displayed many irrelevant or empty columns because different programmes were evaluated against a shared union of skill categories.
- Skill definitions and course-skill relationships were largely manual and difficult to generalize across schools.
- Course recommendations were not directly connected to detailed course descriptions, prerequisites, syllabi, and assessment information.
- The platform had limited account, course-feedback, and career-oriented interaction.

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

The course-planning workflow was improved so that students can move from an available-course entry to more detailed course information. After clicking the course id corresponding to "Available courses", the user will be redirected to the detail interface of the corresponding course id.

This design makes recommendations easier to interpret: students can review not only which course is suggested, but also what the course covers and why it may contribute to a competency area.

### 4. Dashboard interaction and user experience

The midterm work also includes dashboard interface, login, and interaction improvements. The login flow separates student and academic-advisor entry points and stores lightweight session information for the prototype. Course-level interaction work introduces a foundation for peer feedback through course comments.

These functions are prototypes rather than a production identity or social system. Official SSO integration, persistent account management, moderation, authorization, and security hardening remain outside the current midterm scope.

## Core Features

### Student dashboard

- Transcript-based academic-record processing.
- GPA and CGPA trajectory visualization.
- Future course portfolio planning.
- Major and general competency visualization.
- Skill-oriented course recommendation.
- Course browsing and detail navigation.
- Exportable academic and competency summaries.

### Academic advisor dashboard

- Advisee academic-progress overview.
- GPA and credit-completion indicators.
- Risk indicators based on GPA decline, credit delay, and contact history.
- Advisor communication and contact-log information.
- Aggregated progress information for earlier academic intervention.

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
|   `-- data.js
|-- assets/
|-- dataset/
|-- course_list_database/
|   |-- All_Course_Lists.xlsx
|   |-- Course_List_byInitial.xlsx
|   `-- sis_course_outlines_export.xlsx
|-- tools/
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
pip install fastapi "uvicorn[standard]" mysql-connector-python
```

Create the local database and import the provided schema and demonstration data:

```bash
mysql -u root -p -e "CREATE DATABASE course_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p course_db < course_db_api_tables.sql
```

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

- `All Courses`: all 3,358 collected records;
- `With Outline`: 1,727 courses with available outline information; and
- `Missing Outline`: 1,631 courses without complete outline information.

### Major competency workbook

[`competency-analysis/major_competency_ai_review.xlsx`](competency-analysis/major_competency_ai_review.xlsx) summarizes professional competencies inferred from programme study schemes and records the curriculum evidence supporting each interpretation.

### Course-competency workbook

[`competency-analysis/a_to_z_course_competency_relevance.xlsx`](competency-analysis/a_to_z_course_competency_relevance.xlsx) contains detailed course-competency relevance records, course summaries, competency pools, excluded courses, and method notes.

## Success Criteria and Current Evidence

| Criterion | Midterm evidence |
|---|---|
| Expand course coverage beyond the original prototype | Increased from approximately 408 to 3,358 course records |
| Preserve detailed course-outline information | 1,727 courses with valid outlines and structured fields |
| Replace one universal skill list with discipline-aware competency pools | Major competency analysis and school-level competency pools |
| Produce reusable course-competency results | 1,591 scored courses and 13,907 relevance records |
| Improve course-planning interpretability | Course-detail navigation and competency sub-attribute display |
| Provide verifiable implementation evidence | Source code, datasets, workbooks, screenshots, and video demonstration |

## Demonstration Evidence

The complete midterm video evidence package is available through the [latest GitHub Release](https://github.com/re-stellaris/Student-dashboard-demo/releases/latest).

The package includes:

- a demonstration of the newly implemented dashboard functions; and
- a demonstration of the database and data-analysis workflow.

## Verification

The midterm prototype is evaluated through the following checks:

1. The React frontend builds successfully.
2. The FastAPI service starts and exposes the configured routes.
3. `GET /health` reports the database-connection state.
4. Student and advisor navigation routes load successfully.
5. Course data can be loaded from the configured database or bundled prototype data.
6. The generated course and competency workbooks contain the documented record counts and worksheets.
7. Screenshots and video evidence demonstrate the implemented workflows.

## Known Limitations and Risks

- The current login interface is a prototype and is not official CUHK-Shenzhen SSO.
- Some user and planning state is stored in browser storage rather than a production account system.
- Account and comment functionality requires persistent storage, authorization, moderation, and security testing before production use.
- Course exemptions, credit transfers, exchange courses, and approved substitutions require a manual-input workflow.
- 1,631 SIS records do not currently contain complete outline information.
- Competency relevance is an AI-assisted analytical result and requires human review.
- The competency score represents relevance, not student mastery, course quality, or career value.
- The prototype has not been tested against a full production student database or university identity system.
- SIS page changes may require maintenance of crawler selectors and navigation logic.

## Plan Toward Final Delivery

The remaining development direction includes:

- integrating the expanded course database into all dashboard workflows;
- adding overall, UCore, and major-requirement progress indicators;
- supporting manual entry of exemptions and transferred credits;
- strengthening account, comment, authorization, and moderation logic;
- validating competency results through expert review and representative course samples;
- adding career-oriented analysis based on job descriptions and required skills; and
- conducting broader functional, usability, and data-quality testing.

## Team Contributions

| Team member | Primary contribution | Main deliverables |
|---|---|---|
| **Gao Jingwen** | Course catalogue expansion and AI-assisted competency-analysis workflow | SIS crawler, export workflow, expanded course database, major competency skill, analysis scripts, evidence files, and final Excel workbooks |
| **Qu Yicheng** | Dashboard usability and interaction improvements | Dashboard basic-function updates, GPA and skill-matrix UI improvements, course navigation, login/interface work, and course-interaction design |

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
