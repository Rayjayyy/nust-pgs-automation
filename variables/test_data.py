# ============================================================
# Test data for the NUST PGS Robot Framework automation suite.
# Values are aligned with database/demo-seed.sql and seed.sql.
# ============================================================

# ---------- Student (demo-seed id=100) ----------------------------------------
STUDENT_FIRST_NAME   = "Tendai"
STUDENT_LAST_NAME    = "Moyo"
STUDENT_FULL_NAME    = "Tendai Moyo"
STUDENT_EMAIL        = "tendai.moyo@students.nust.na"
STUDENT_NUMBER       = "20250001"
STUDENT_PROGRAMME    = "PhD Computer Science"
STUDENT_THESIS_TITLE = "Machine Learning Approaches for Early Detection of Crop Diseases in Sub-Saharan Africa"
STUDENT_YEAR         = "2025"
STUDENT_SEMESTER     = "December"
STUDENT_DEGREE_LABEL = "Doctor of Philosophy in Computer Science"

# ---------- Supervisor (demo-seed id=101) -------------------------------------
SUPERVISOR_FIRST_NAME = "James"
SUPERVISOR_LAST_NAME  = "Chikwanha"
SUPERVISOR_FULL_NAME  = "James Chikwanha"
SUPERVISOR_EMAIL      = "j.chikwanha@nust.na"
SUPERVISOR_DEPT       = "Computer Science"

# ---------- Internal Evaluator (demo-seed id=102) -----------------------------
INT_EVAL_FIRST_NAME = "Elizabeth"
INT_EVAL_LAST_NAME  = "Kamati"
INT_EVAL_FULL_NAME  = "Elizabeth Kamati"
INT_EVAL_EMAIL      = "e.kamati@nust.na"
INT_EVAL_DEPT       = "Computer Science"

# ---------- External Evaluator (seed.sql) -------------------------------------
EXT_EVAL_FULL_NAME     = "Dr. Moyo"
EXT_EVAL_EMAIL         = "external@nust.na"
EXT_EVAL_INSTITUTION   = "University of Namibia"
EXT_EVAL_SPECIALISATION = "Machine Learning"
EXT_EVAL_BANK          = "First National Bank"
EXT_EVAL_ACCOUNT       = "62123456789"
EXT_EVAL_BRANCH_CODE   = "280172"

# ---------- HoD (seed.sql) ----------------------------------------------------
HOD_FIRST_NAME  = "Prof"
HOD_LAST_NAME   = "Amadhila"
HOD_FULL_NAME   = "Prof Amadhila"
HOD_EMAIL       = "hod@nust.na"
HOD_DEPT        = "Computer Science"

# ---------- FPGCR (seed.sql) --------------------------------------------------
FPGCR_FULL_NAME = "Ms Nekundi"
FPGCR_EMAIL     = "fpgcr@nust.na"

# ---------- FPGC (seed.sql) ---------------------------------------------------
FPGC_FULL_NAME  = "Committee Member"
FPGC_EMAIL      = "fpgc@nust.na"

# ---------- New account for registration tests --------------------------------
NEW_FIRST_NAME  = "Rudo"
NEW_LAST_NAME   = "Chikara"
NEW_EMAIL       = "rudo.chikara.test@students.nust.na"
NEW_PASSWORD    = "SecurePass@2026"

# ---------- Progress Report fields (progress_reports table) -------------------
PR_YEAR_UNDER_REVIEW    = "2025"
PR_SEMESTER_END         = "December"
PR_RESEARCH_TITLE       = "Machine Learning Approaches for Early Detection of Crop Diseases in Sub-Saharan Africa"
PR_DEGREE_LABEL         = "Doctor of Philosophy in Computer Science"
PR_PROBLEM_STATEMENT    = "Crop diseases cause significant yield losses in sub-Saharan Africa."
PR_RESEARCH_OBJECTIVES  = "1. Collect disease image datasets. 2. Train CNN models. 3. Evaluate accuracy."
PR_ACTIVITIES_COMPLETED = "Literature review completed. Dataset collection phase initiated."
PR_OUTPUTS_DELIVERED    = "Chapter 1 and Chapter 2 drafts submitted."
PR_ON_SCHEDULE          = "yes"
PR_ON_BUDGET            = "yes"
PR_ON_TARGET            = "yes"
PR_CHALLENGES           = "Limited access to high-resolution satellite imagery."
PR_STUDENT_COMMENTS     = "Overall progress is satisfactory."

# ---------- Summary of Proposals fields (summary_of_proposals table) ---------
SOP_THESIS_TYPE          = "thesis"
SOP_BACKGROUND           = "Crop disease detection in sub-Saharan Africa relies on manual inspection."
SOP_PROBLEM_STATEMENT    = "Manual crop disease inspection is slow, costly, and error-prone."
SOP_OBJECTIVES           = "To develop a CNN-based crop disease detection system."
SOP_RESEARCH_QUESTIONS   = "1. Which CNN architecture best suits the dataset? 2. What accuracy is achievable?"
SOP_LITERATURE_REVIEW    = "Several studies have used ResNet and VGG architectures for plant disease detection."
SOP_THEORETICAL_FRAMEWORK = "Transfer learning applied to ImageNet-pretrained models."
SOP_DATA_COLLECTION      = "Images captured from experimental farms in Namibia."
SOP_DATA_ANALYSIS        = "Convolutional neural networks trained on labelled disease images."
SOP_ETHICAL_ISSUES       = "No human subjects involved. Institutional approval obtained."
SOP_SIGNIFICANCE         = "Reduces crop losses and improves food security."

# ---------- Honorarium claim fields (honorarium_claims table) ----------------
CLAIM_SURNAME       = "Moyo"
CLAIM_NAMES         = "Dr Examiner"
CLAIM_PROGRAMME     = "PhD Computer Science"
CLAIM_EXAM_SESSION  = "November"
CLAIM_EXAM_YEAR     = "2025"
CLAIM_SUBTOTAL      = "2500.00"
CLAIM_TAX           = "375.00"
CLAIM_TOTAL         = "2875.00"

# ---------- Supervisor sign / comment text ------------------------------------
SUPERVISOR_COMMENT      = ("The student has made good progress. The literature review is comprehensive. "
                           "Methodology needs additional detail.")
SUPERVISOR_SIGN_REMARK  = "I confirm this Progress Report is accurate and reflects the student's progress."
EVALUATOR_REMARKS       = ("The proposal is well-structured and the research questions are clear. "
                           "The theoretical framework needs strengthening.")
HDC_DECISION_NOTES      = "Approved by the Higher Degrees Committee at the June 2025 meeting."

# ---------- Academic master data (seed.sql) ----------------------------------
FACULTY_COMPUTING   = "Faculty of Computing"
DEPARTMENT_CS       = "Computer Science"
PROGRAMME_MSC_CS    = "MSc Computer Science"
PROGRAMME_PHD_CS    = "PhD Computer Science"
ACADEMIC_YEAR       = "2025/2026"
