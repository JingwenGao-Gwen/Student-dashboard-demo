---
name: extract-graduation-rules
description: Extract evidence-grounded, cohort-specific graduation requirements from university study-scheme PDFs and convert them into human-reviewable and machine-readable rule drafts. Use when analysing required courses, alternative course combinations, elective pools, unit or course-count thresholds, breadth/depth constraints, streams or concentrations, capstones, exemptions, substitutions, double-counting restrictions, special notes, or changes between programme admission years before implementing a study-progress calculator.
---

# Extract Graduation Rules

## Purpose

Turn study schemes into auditable rule drafts without confusing automated text extraction with final academic interpretation. Treat every programme, admission cohort, and compulsory stream or concentration as a potentially different rule set.

Read [references/rule-interpretation-framework.md](references/rule-interpretation-framework.md) before interpreting a scheme or designing the output schema.

## Required Outputs

Produce both:

1. A human-review Markdown file containing the interpreted rules, source references, evidence, cohort differences, and unresolved questions.
2. A structured JSON draft suitable for later conversion into executable programme/cohort rules.

Keep the draft status explicit until a human reviewer confirms the interpretation. Never present keyword matches or extracted snippets as final rules.

## Workflow

### 1. Inventory the source schemes

- Group documents by school, programme, admission year, and stream or concentration.
- Read the scheme's applicability statement; do not derive the cohort solely from a filename when the document provides stronger evidence.
- Interpret “and thereafter” as an open-ended range only until a later superseding scheme is found.
- Record the exact source filename and page for every rule set.
- Flag missing, duplicated, corrupted, or conflicting documents.

### 2. Run high-recall extraction

- Extract the full PDF text and retain page boundaries.
- Find programme titles, applicable admission years, total-unit clues, section headings, course codes, units, tables, and footnotes.
- Capture broad evidence around phrases such as “required,” “selected from,” “either,” “at least,” “at most,” “stream,” “concentration,” “exempted,” “substitute,” and “subject to approval.”
- Normalize obvious whitespace and course-code formatting while preserving the original wording as evidence.
- If an existing parser is available, use it only to generate candidates for review.

### 3. Apply the manual interpretation framework

- Separate university core, school package, major required, major elective, free elective, capstone, internship, and other named components.
- Convert each compulsory course into a one-course mandatory group.
- Convert “A or B” into one any-one mandatory group.
- Preserve compound alternatives such as “(A and B) or (C and D)” as alternative combinations; never flatten them into four independent choices.
- Model selection rules by their stated metric: units, number of courses, categories, or combinations.
- Capture category-specific minimums, course-level maximums, breadth, depth, required streams, optional streams, and concentration-specific pools.
- Encode exemptions, approved substitutions, equivalent course codes, exclusions, double-counting limits, transfer-course conditions, and footnotes separately.
- Distinguish graduation requirements from recommended course patterns and prerequisites.

### 4. Compare academic years

- Build one variant for each materially different admission cohort.
- Compare adjacent variants field by field.
- Record courses added or removed, changed alternatives, changed unit thresholds, renamed categories, and changed stream logic.
- Merge multiple years only when the source and interpreted rules are genuinely identical.

### 5. Validate the interpretation

- Check whether component units reconcile with the stated total. Explain rather than conceal mismatches.
- Check that every alternative is grouped correctly and every elective pool has a threshold.
- Check shortened codes in tables against their inherited subject prefix.
- Check bilingual sections and footnotes for information lost in text extraction.
- Check that a course cannot satisfy multiple categories unless the scheme permits it.
- Place every uncertainty in an issue ledger with source page, evidence, proposed interpretation, and review status.

### 6. Hand off for programming

- Keep evidence and interpretation separate from executable logic.
- After human approval, transform the reviewed draft through programming into the application's rule schema.
- Add explicit engine semantics for every non-basic constraint, such as `minUnitsByCategory`, `maxLevelCourses`, `breadth`, `depth`, `optionalStreamDeclaration`, and `exactMajorPool`.
- Test the programmed rules with boundary cases before using them to calculate student progress.

## Student-Matching Extension

When asked to calculate a student's progress after rule extraction:

- Identify programme, admission year, and declared stream from authoritative student data or the transcript.
- Match the student to exactly one reviewed cohort variant; flag ambiguity instead of choosing silently.
- Keep completed, in-progress, planned, transferred, exempted, and failed courses distinct.
- Apply substitution and non-double-counting rules before computing completed and remaining requirements.
- Show both the result and the matched cohort/source so the calculation remains auditable.

## Quality Rules

- Cite evidence close to every interpreted rule.
- Prefer `unknown` plus a review question over unsupported inference.
- Preserve the original wording for unusual constraints.
- Do not infer units from a typical course value when the scheme does not state them.
- Do not treat a recommended term pattern as a graduation condition.
- Do not claim complete programme coverage when some schemes failed extraction or review.
