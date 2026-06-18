#!/Applications/miniconda3/bin/python3
"""
CUHKSZ Course App — Single Server
Run:   python3 api_server.py
Open:  http://localhost:8000
"""

from fastapi import FastAPI, HTTPException, Query
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
import mysql.connector
import json
import os
from datetime import date
import re
from urllib.parse import urlparse

# ── Config ──────────────────────────────────────────────────────────
def _build_db_config():
    mysql_url = os.getenv("MYSQL_URL", "").strip()
    if mysql_url:
        u = urlparse(mysql_url)
        cfg = {
            "host": u.hostname or "localhost",
            "port": int(u.port or 3306),
            "database": (u.path or "/").lstrip("/") or "course_db",
            "user": u.username or "root",
            "password": u.password or "",
        }
    else:
        cfg = {
            "host":     os.getenv("DB_HOST", "localhost"),
            "port":     int(os.getenv("DB_PORT", "3306")),
            "database": os.getenv("DB_NAME", "course_db"),
            "user":     os.getenv("DB_USER", "root"),
            "password": os.getenv("DB_PASSWORD", ""),
        }

    # For managed cloud MySQL, SSL is typically required.
    ssl_disabled = os.getenv("DB_SSL_DISABLED", "false").lower() == "true"
    if not ssl_disabled:
        cfg["ssl_disabled"] = False
    return cfg

DB_CONFIG = _build_db_config()

SHEET_TO_DEPT = {
    "ACT":  "ACT",
    "AACT": "ACT",
    "FIN":  "FIN",
    "MGT":  "MGT",
    "MKT":  "MKT",
    "MIS":  "MIS",
    "CSC":  "CSC",
    "MAT":  "MAT",
    "GE":   "GEN",
    "PED":  "GEN",
}

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FRONTEND_DIST_DIR = os.path.join(BASE_DIR, "frontend", "dist")

# ── App ─────────────────────────────────────────────────────────────
app = FastAPI(title="CUHKSZ Course App")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["*"],
)

# ── DB helpers ───────────────────────────────────────────────────────
def get_connection():
    return mysql.connector.connect(**DB_CONFIG)

def safe_json(value):
    if not value:
        return []
    try:
        parsed = json.loads(value)
        return parsed if isinstance(parsed, list) else [str(parsed)]
    except (json.JSONDecodeError, TypeError):
        parts = [p.strip() for p in str(value).replace(";", "\n").splitlines() if p.strip()]
        return parts or [str(value)]

def _student_display_name(row):
    first = (row.get("first_name") or "").strip()
    last = (row.get("last_name") or "").strip()
    if first or last:
        return f"{first} {last}".strip()
    return (row.get("username") or row.get("student_id") or "Student").strip()

def _to_year_label(year_enrolled):
    if not year_enrolled:
        return "Year 1"
    current = date.today().year
    year = current - int(year_enrolled)
    if year < 1:
        year = 1
    if year > 4:
        year = 4
    return f"Year {year}"

_SEM_RE = re.compile(r"^(\d{4})-(\d{2})\s+(Term\s+\d+|Summer)$")

def _semester_sort_key(sem):
    text = (sem or "").strip()
    m = _SEM_RE.match(text)
    if not m:
        return (9999, 9, text)
    year_start = int(m.group(1))
    tail = m.group(3)
    if tail == "Term 1":
        phase = 1
    elif tail == "Term 2":
        phase = 2
    else:
        phase = 3
    return (year_start, phase, text)

def _norm(s):
    return (str(s or "")).strip().lower()

def _first_present(row, keys):
    for k in keys:
        if k in row and row.get(k) is not None:
            return row.get(k)
    return None

# ── API routes (must be defined BEFORE static mount) ────────────────
@app.get("/api/courses")
def get_courses():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT sheet_name, course_code, title, lang,
                   description, outcome, syllabus, assessment,
                   reading_material, prerequisites, co_requisites
            FROM courses
            ORDER BY sheet_name, course_code
        """)
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
    except mysql.connector.Error as e:
        raise HTTPException(status_code=500, detail=f"DB error: {e}")

    courses = []
    for r in rows:
        sheet = (r["sheet_name"] or "").strip().upper()
        dept  = SHEET_TO_DEPT.get(sheet, sheet or "OTHER")
        courses.append({
            "code":             (r["course_code"] or "").strip(),
            "title":            (r["title"] or "").strip(),
            "dept":             dept,
            "sheet_name":       sheet,
            "lang":             (r["lang"] or "").strip(),
            "description":      (r["description"] or "").strip(),
            "outcomes":         safe_json(r["outcome"]),
            "syllabus":         (r["syllabus"] or "").strip(),
            "assessment":       (r["assessment"] or "").strip(),
            "reading_material": (r["reading_material"] or "").strip(),
            "prerequisites":    (r["prerequisites"] or "").strip(),
            "co_requisites":    (r["co_requisites"] or "").strip(),
        })

    return {"courses": courses, "total": len(courses)}


@app.get("/api/courses/{course_code:path}")
def get_course(course_code: str):
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM courses WHERE course_code = %s LIMIT 1", (course_code,))
        row = cursor.fetchone()
        cursor.close()
        conn.close()
    except mysql.connector.Error as e:
        raise HTTPException(status_code=500, detail=f"DB error: {e}")

    if not row:
        raise HTTPException(status_code=404, detail="Course not found")

    sheet = (row["sheet_name"] or "").strip().upper()
    return {
        **{k: (v or "") for k, v in row.items()},
        "dept":     SHEET_TO_DEPT.get(sheet, sheet),
        "outcomes": safe_json(row["outcome"]),
    }

@app.get("/api/advising/dashboard")
def get_advising_dashboard():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                s.student_id,
                s.username,
                s.first_name,
                s.last_name,
                s.major,
                s.year_enrolled,
                s.gpa,
                s.total_credits,
                sc.school_name,
                MAX(acl.contact_date) AS last_contact_date,
                COUNT(acl.id) AS contacts_count
            FROM students s
            LEFT JOIN majors m
                ON s.major = m.major_name
            LEFT JOIN schools sc
                ON m.school_id = sc.school_id
            LEFT JOIN advisor_contact_log acl
                ON acl.student_id = s.student_id
            GROUP BY
                s.student_id, s.username, s.first_name, s.last_name,
                s.major, s.year_enrolled, s.gpa, s.total_credits, sc.school_name
            ORDER BY s.student_id
        """)
        student_rows = cursor.fetchall()

        cursor.execute("""
            SELECT id, student_id, semester, term_gpa
            FROM gpa_history
            ORDER BY id
        """)
        gpa_rows = cursor.fetchall()

        cursor.execute("""
            SELECT student_id, contact_date, contact_type, notes
            FROM advisor_contact_log
            ORDER BY contact_date DESC, id DESC
        """)
        contact_rows = cursor.fetchall()

        cursor.execute("""
            SELECT student_id, category, COUNT(*) AS course_count
            FROM enrollment
            WHERE status = 'Completed'
            GROUP BY student_id, category
        """)
        enrollment_rows = cursor.fetchall()

        cursor.close()
        conn.close()
    except mysql.connector.Error as e:
        raise HTTPException(status_code=500, detail=f"DB error: {e}")

    today = date.today()

    gpa_by_student = {}
    sem_buckets = {}
    for r in gpa_rows:
        sid = r["student_id"]
        gpa_by_student.setdefault(sid, []).append({
            "semester": (r.get("semester") or "").strip(),
            "term_gpa": float(r["term_gpa"]) if r.get("term_gpa") is not None else None
        })
        sem = (r.get("semester") or "").strip()
        if sem and r.get("term_gpa") is not None:
            sem_buckets.setdefault(sem, []).append(float(r["term_gpa"]))

    contact_by_student = {}
    for r in contact_rows:
        sid = r["student_id"]
        contact_by_student.setdefault(sid, []).append({
            "date": r["contact_date"].isoformat() if r.get("contact_date") else None,
            "type": (r.get("contact_type") or "").strip(),
            "notes": (r.get("notes") or "").strip(),
        })

    cat_by_student = {}
    for r in enrollment_rows:
        sid = r["student_id"]
        cat = (r.get("category") or "Other").strip()
        cnt = int(r.get("course_count") or 0)
        cat_by_student.setdefault(sid, {})
        cat_by_student[sid][cat] = cnt

    students = []
    gpa_distribution = {"lt2": 0, "2to25": 0, "25to3": 0, "3to35": 0, "ge35": 0}

    total_completion_pct = 0.0
    total_students = 0
    communication_recent = 0
    comm_no_contact = 0
    comm_1_2 = 0
    comm_3_plus = 0

    major_courses = 0
    core_courses = 0
    elective_courses = 0
    major_elective_courses = 0
    free_elective_courses = 0

    for row in student_rows:
        sid = row["student_id"]
        name = _student_display_name(row)
        year_label = _to_year_label(row.get("year_enrolled"))
        major = (row.get("major") or "Undeclared").strip()
        school = (row.get("school_name") or "Unknown School").strip()
        gpa = float(row["gpa"]) if row.get("gpa") is not None else 0.0
        total_credits = int(row.get("total_credits") or 0)

        completion_pct = max(0.0, min(100.0, (total_credits / 120.0) * 100.0))
        total_completion_pct += completion_pct
        total_students += 1

        if gpa < 2.0:
            gpa_distribution["lt2"] += 1
        elif gpa < 2.5:
            gpa_distribution["2to25"] += 1
        elif gpa < 3.0:
            gpa_distribution["25to3"] += 1
        elif gpa < 3.5:
            gpa_distribution["3to35"] += 1
        else:
            gpa_distribution["ge35"] += 1

        last_contact = row.get("last_contact_date")
        last_contact_iso = last_contact.isoformat() if last_contact else None
        last_contact_days = (today - last_contact).days if last_contact else 999
        if last_contact_days <= 90:
            communication_recent += 1

        contacts_count = int(row.get("contacts_count") or 0)
        if contacts_count == 0:
            comm_no_contact += 1
        elif contacts_count <= 2:
            comm_1_2 += 1
        else:
            comm_3_plus += 1

        hist = gpa_by_student.get(sid, [])
        gpa_decline = 0.0
        if len(hist) >= 2:
            latest = hist[-1].get("term_gpa")
            prev = hist[-2].get("term_gpa")
            if latest is not None and prev is not None and prev > latest:
                gpa_decline = round(prev - latest, 3)

        year_num = int(year_label.split(" ")[1])
        expected_credits = year_num * 30
        credit_delay = max(0, expected_credits - total_credits)
        final_urgency = 100 if (year_num >= 4 and completion_pct < 85) else (50 if year_num >= 4 and completion_pct < 100 else 0)

        gpa_signal = min(100.0, (gpa_decline / 0.5) * 100.0) if gpa_decline > 0 else 0.0
        credit_signal = min(100.0, (credit_delay / 30.0) * 100.0) if credit_delay > 0 else 0.0
        contact_signal = min(100.0, (last_contact_days / 120.0) * 100.0) if last_contact_days > 0 else 0.0
        risk_score = round((0.40 * gpa_signal) + (0.30 * credit_signal) + (0.20 * contact_signal) + (0.10 * final_urgency))

        if risk_score >= 85:
            risk_level = "High"
        elif risk_score >= 70:
            risk_level = "Medium"
        else:
            risk_level = "Low"

        tags = []
        if gpa_decline >= 0.30:
            tags.append("gpa")
        if credit_delay > 0:
            tags.append("credit")
        if last_contact_days > 90:
            tags.append("contact")
        if final_urgency > 0:
            tags.append("final")
        if not tags:
            tags.append("monitor")

        reason_map = {
            "gpa": "GPA drop",
            "credit": "Credit delay",
            "contact": "No recent contact",
            "final": "Final-year urgency",
            "monitor": "General monitoring"
        }
        reason_text = " + ".join(reason_map[t] for t in tags[:2])

        by_cat = cat_by_student.get(sid, {})
        major_cnt = int(by_cat.get("Major", 0))
        core_cnt = int(by_cat.get("GenEd", 0))
        elective_cnt = sum(v for k, v in by_cat.items() if k not in ("Major", "GenEd"))

        # Demo-friendly split for electives:
        # 1) prefer explicit categories if they exist in DB
        # 2) otherwise split generic electives into major/free electives
        explicit_major_elective = int(
            by_cat.get("Major Elective", 0)
            or by_cat.get("MajorElective", 0)
            or by_cat.get("Major_Elective", 0)
        )
        explicit_free_elective = int(
            by_cat.get("Free Elective", 0)
            or by_cat.get("FreeElective", 0)
            or by_cat.get("Free_Elective", 0)
        )
        if explicit_major_elective or explicit_free_elective:
            major_elective_cnt = explicit_major_elective
            free_elective_cnt = explicit_free_elective
        else:
            # Fake split for presentation: 60% major elective, 40% free elective
            major_elective_cnt = int(round(elective_cnt * 0.6))
            free_elective_cnt = max(0, elective_cnt - major_elective_cnt)

        major_courses += major_cnt
        core_courses += core_cnt
        elective_courses += elective_cnt
        major_elective_courses += major_elective_cnt
        free_elective_courses += free_elective_cnt

        students.append({
            "student_id": sid,
            "name": name,
            "year_label": year_label,
            "major": major,
            "school": school,
            "gpa": round(gpa, 3),
            "total_credits": total_credits,
            "completion_pct": round(completion_pct, 1),
            "last_contact_date": last_contact_iso,
            "last_contact_days": int(last_contact_days),
            "contacts_count": contacts_count,
            "risk_score": int(risk_score),
            "risk_level": risk_level,
            "risk_tags": tags,
            "reason_text": reason_text,
            "gpa_decline": gpa_decline,
            "credit_delay": int(credit_delay),
            "history": contact_by_student.get(sid, []),
            "gpa_terms": hist,
            "notes": "",
            "missing_courses": {"Major Required": [], "Electives": [], "University Core": []},
            "category_progress": {
                "major_courses": major_cnt,
                "core_courses": core_cnt,
                "elective_courses": elective_cnt,
                "major_elective_courses": major_elective_cnt,
                "free_elective_courses": free_elective_cnt
            }
        })

    sem_items = []
    for sem, vals in sem_buckets.items():
        sem_items.append({
            "semester": sem,
            "avg_gpa": round(sum(vals) / len(vals), 3)
        })
    sem_items.sort(key=lambda x: _semester_sort_key(x["semester"]))

    major_credits = major_courses * 3
    core_credits = core_courses * 3
    elective_credits = elective_courses * 3
    major_elective_credits = major_elective_courses * 3
    free_elective_credits = free_elective_courses * 3

    # Per-student fixed credit targets (must sum to 120)
    MAJOR_TARGET = 36
    ELECTIVE_TARGET = 24
    FREE_ELECTIVE_TARGET = 30
    CORE_TARGET = 30

    n = max(1, total_students)
    avg_major_done = round(major_credits / n, 1)
    avg_elective_done = round(elective_credits / n, 1)
    avg_major_elective_done = round(major_elective_credits / n, 1)
    avg_free_elective_done = round(free_elective_credits / n, 1)
    avg_core_done = round(core_credits / n, 1)

    major_pct = round(min(100, (avg_major_done / MAJOR_TARGET) * 100), 1)
    elective_pct = round(min(100, (avg_major_elective_done / ELECTIVE_TARGET) * 100), 1)
    free_elective_pct = round(min(100, (avg_free_elective_done / FREE_ELECTIVE_TARGET) * 100), 1)
    core_pct = round(min(100, (avg_core_done / CORE_TARGET) * 100), 1)

    total_done_credits = major_credits + core_credits + elective_credits
    remaining_credits = max(0, 120 * n - total_done_credits)

    avg_completion = round((total_completion_pct / total_students), 1) if total_students else 0.0
    avg_credits_done = round(sum(s["total_credits"] for s in students) / total_students, 1) if total_students else 0.0

    students.sort(key=lambda x: (-x["risk_score"], x["name"]))
    high_risk_count = len([s for s in students if s["risk_score"] >= 85])

    return {
        "generated_at": date.today().isoformat(),
        "students": students,
        "overview": {
            "gpa_distribution": {
                "labels": ["<2.0", "2.0-2.5", "2.5-3.0", "3.0-3.5", ">=3.5"],
                "values": [
                    gpa_distribution["lt2"],
                    gpa_distribution["2to25"],
                    gpa_distribution["25to3"],
                    gpa_distribution["3to35"],
                    gpa_distribution["ge35"],
                ]
            },
            "gpa_trend": {
                "labels": [s["semester"] for s in sem_items],
                "values": [s["avg_gpa"] for s in sem_items]
            },
            "progress": {
                "avg_completion_pct": avg_completion,
                "avg_credits_done": avg_credits_done,
                "avg_credits_total": 120,
                "major": {"done": avg_major_done, "target": MAJOR_TARGET, "pct": major_pct},
                "elective": {"done": avg_major_elective_done, "target": ELECTIVE_TARGET, "pct": elective_pct},
                "free_elective": {"done": avg_free_elective_done, "target": FREE_ELECTIVE_TARGET, "pct": free_elective_pct},
                "core": {"done": avg_core_done, "target": CORE_TARGET, "pct": core_pct},
                "pie": {
                    "major": avg_major_done,
                    "elective": avg_major_elective_done,
                    "free_elective": avg_free_elective_done,
                    "core": avg_core_done,
                    "remaining": max(0, 120 - avg_major_done - avg_major_elective_done - avg_free_elective_done - avg_core_done)
                }
            },
            "communication": {
                "total_students": len(students),
                "recently_contacted": communication_recent,
                "no_contact": comm_no_contact,
                "contacts_1_2": comm_1_2,
                "contacts_3_plus": comm_3_plus
            }
        },
        "risk_summary": {
            "high_risk_count": high_risk_count,
            "credit_alert_count": len([s for s in students if "credit" in s["risk_tags"]]),
            "gpa_drop_count": len([s for s in students if "gpa" in s["risk_tags"]]),
            "no_contact_count": len([s for s in students if "contact" in s["risk_tags"]]),
        }
    }

@app.get("/api/auth/advisor")
def auth_advisor(
    username: str = Query(""),
    email: str = Query("")
):
    """
    Validate advisor login credentials using ONLY the advisors table.
    Column names are detected dynamically so this works with schema variants.
    """
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT COLUMN_NAME
            FROM information_schema.columns
            WHERE table_schema = DATABASE()
              AND table_name = 'advisors'
        """)
        col_rows = cursor.fetchall()
        advisor_cols = {r["COLUMN_NAME"] for r in col_rows}
        if not advisor_cols:
            raise HTTPException(status_code=500, detail="advisors table not found")

        select_cols = ", ".join(f"`{c}`" for c in sorted(advisor_cols))

        email_col = None
        for c in ("email", "advisor_email", "campus_email"):
            if c in advisor_cols:
                email_col = c
                break
        if not email_col:
            raise HTTPException(status_code=500, detail="No email column found in advisors table")

        cursor.execute(
            f"SELECT {select_cols} FROM advisors WHERE LOWER(TRIM(`{email_col}`)) = %s",
            (_norm(email),)
        )
        advisors = cursor.fetchall()

        cursor.close()
        conn.close()
    except mysql.connector.Error as e:
        raise HTTPException(status_code=500, detail=f"DB error: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {e}")

    norm_username = _norm(username)
    norm_email = _norm(email)

    matched = None
    for row in advisors:
        if _norm(row.get("email")) != norm_email:
            continue
        if norm_username and _norm(row.get("username")) != norm_username:
            continue
        matched = row
        break

    if not matched:
        return {"ok": False}

    school_name = str(matched.get("department") or "").strip()
    advisor_name = str(matched.get("username") or "").strip()
    advisor_email = str(matched.get("email") or "").strip()
    advisor_id = str(matched.get("advisor_id") or "").strip()

    return {
        "ok": True,
        "advisor": {
            "advisor_id": advisor_id,
            "full_name": advisor_name,
            "email": advisor_email,
            "school": school_name
        }
    }


@app.get("/api/auth/student")
def auth_student(
    username: str = Query(""),
    email: str = Query("")
):
    """
    Validate student login credentials using ONLY the students table.
    Column names are detected dynamically so this works with schema variants.
    """
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT COLUMN_NAME
            FROM information_schema.columns
            WHERE table_schema = DATABASE()
              AND table_name = 'students'
        """)
        col_rows = cursor.fetchall()
        student_cols = {r["COLUMN_NAME"] for r in col_rows}
        if not student_cols:
            raise HTTPException(status_code=500, detail="students table not found")

        select_cols = ", ".join(f"`{c}`" for c in sorted(student_cols))

        email_col = None
        for c in ("email", "student_email", "campus_email"):
            if c in student_cols:
                email_col = c
                break
        if not email_col:
            raise HTTPException(status_code=500, detail="No email column found in students table")

        username_col = None
        for c in ("username", "full_name", "name", "student_name"):
            if c in student_cols:
                username_col = c
                break
        if not username_col:
            raise HTTPException(status_code=500, detail="No username column found in students table")

        cursor.execute(
            f"SELECT {select_cols} FROM students WHERE LOWER(TRIM(`{email_col}`)) = %s",
            (_norm(email),)
        )
        students = cursor.fetchall()

        cursor.close()
        conn.close()
    except mysql.connector.Error as e:
        raise HTTPException(status_code=500, detail=f"DB error: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {e}")

    norm_username = _norm(username)
    norm_email = _norm(email)

    matched = None
    for row in students:
        if _norm(row.get(email_col)) != norm_email:
            continue
        if norm_username and _norm(row.get(username_col)) != norm_username:
            continue
        matched = row
        break

    if not matched:
        return {"ok": False}

    return {
        "ok": True,
        "student": {
            "full_name": str(matched.get(username_col) or "").strip(),
            "email": str(matched.get(email_col) or "").strip()
        }
    }


@app.get("/health")
def health():
    try:
        conn = get_connection()
        conn.close()
        return {"status": "ok", "db": "connected"}
    except Exception as e:
        return {"status": "error", "detail": str(e)}


# ── Explicit HTML page routes ────────────────────────────────────────
NO_CACHE = {"Cache-Control": "no-store, no-cache, must-revalidate", "Pragma": "no-cache"}

@app.get("/")
def root():
    index_file = os.path.join(FRONTEND_DIST_DIR, "index.html")
    if os.path.exists(index_file):
        return FileResponse(index_file, headers=NO_CACHE)
    return RedirectResponse(url="/app", status_code=307, headers=NO_CACHE)

@app.get("/index.html")
def serve_index():
    return FileResponse(os.path.join(BASE_DIR, "index.html"), headers=NO_CACHE)

@app.get("/student_dashboard.html")
def serve_student_dashboard_legacy():
    return FileResponse(os.path.join(BASE_DIR, "students-interface", "student_dashboard_index.html"), headers=NO_CACHE)

@app.get("/student_dashboard_guide.html")
def serve_student_guide_legacy():
    return FileResponse(os.path.join(BASE_DIR, "students-interface", "student_dashboard_guide.html"), headers=NO_CACHE)

@app.get("/student_interface.html")
def serve_student():
    return FileResponse(os.path.join(BASE_DIR, "student_interface.html"), headers=NO_CACHE)

@app.get("/aa_dashboard.html")
def serve_aa():
    return FileResponse(os.path.join(BASE_DIR, "aa_dashboard.html"), headers=NO_CACHE)

@app.get("/app")
def serve_react_app_root():
    index_file = os.path.join(FRONTEND_DIST_DIR, "index.html")
    if not os.path.exists(index_file):
        raise HTTPException(status_code=404, detail="React app not built yet. Run: npm run frontend:build")
    return FileResponse(index_file)

@app.get("/app/{path:path}")
def serve_react_app(path: str):
    index_file = os.path.join(FRONTEND_DIST_DIR, "index.html")
    candidate = os.path.join(FRONTEND_DIST_DIR, path)
    if os.path.exists(candidate) and os.path.isfile(candidate):
        return FileResponse(candidate)
    if os.path.exists(index_file):
        return FileResponse(index_file)
    raise HTTPException(status_code=404, detail="React app not built yet. Run: npm run frontend:build")

# ── Static files (CSS, JS, assets) — mounted LAST ───────────────────
from fastapi import Request
from fastapi.responses import Response
import os as _os

@app.middleware("http")
async def no_cache_middleware(request: Request, call_next):
    response = await call_next(request)
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    return response

app.mount("/", StaticFiles(directory=BASE_DIR, html=True), name="static")


if __name__ == "__main__":
    import uvicorn
    print("\n  CUHKSZ Course App")
    print("  Open: http://localhost:8080/app\n")
    uvicorn.run(app, host="0.0.0.0", port=8080)
