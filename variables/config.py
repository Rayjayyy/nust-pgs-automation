# ============================================================
# NUST Postgraduate System – Robot Framework configuration
#
# Tech stack : Laravel 11 + Inertia.js + React (TypeScript)
# Auth engine: Laravel Fortify (email / password + 2-FA TOTP)
# Default URL : http://localhost  (APP_URL in .env)
#
# All demo-seed users share the password "password"
# (see database/demo-seed.sql and database/seed.sql).
# ============================================================

BASE_URL    = "http://localhost:8000"
BROWSER     = "chrome"
TIMEOUT     = "30s"
IMPLICIT_WAIT = "10s"

# ---------- Demo / seed credentials (database/demo-seed.sql + seed.sql) -------

# Student – Tendai Moyo (demo-seed.sql id=100)
STUDENT_USER    = "tendai.moyo@students.nust.na"
STUDENT_PASS    = "password"

# Supervisor – Prof. James Chikwanha (demo-seed.sql id=101)
SUPERVISOR_USER = "j.chikwanha@nust.na"
SUPERVISOR_PASS = "password"

# Internal Evaluator – Dr. Elizabeth Kamati (demo-seed.sql id=102)
INT_EVAL_USER   = "e.kamati@nust.na"
INT_EVAL_PASS   = "password"

# Additional seed users (database/seed.sql)
HOD_USER        = "hod@nust.na"
HOD_PASS        = "password"

EXT_EVAL_USER   = "external@nust.na"
EXT_EVAL_PASS   = "password"

FPGCR_USER      = "fpgcr@nust.na"
FPGCR_PASS      = "password"

FPGC_USER       = "fpgc@nust.na"
FPGC_PASS       = "password"

ADMIN_USER      = "admin@nust.na"
ADMIN_PASS      = "password"

# ---------- Invalid / boundary values -----------------------------------------
INVALID_USER    = "no.such.user@nust.na"
INVALID_PASS    = "WrongPassword999"

# ---------- URL paths (derived from routes/web.php + Fortify defaults) --------
URL_HOME            = "/"
URL_LOGIN           = "/login"
URL_REGISTER        = "/register"
URL_DASHBOARD       = "/dashboard"
URL_FORGOT_PW       = "/forgot-password"
URL_SETTINGS_PROFILE    = "/settings/profile"
URL_SETTINGS_SECURITY   = "/settings/security"
URL_SETTINGS_APPEARANCE = "/settings/appearance"
URL_TWO_FACTOR_CHALLENGE = "/two-factor-challenge"
