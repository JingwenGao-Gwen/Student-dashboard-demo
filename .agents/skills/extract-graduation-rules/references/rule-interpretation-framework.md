# Graduation Rule Interpretation Framework

## Rule-set identity

Use the tuple below as the identity of a rule variant:

- school
- programme / major key
- admission-year start and end
- stream or concentration when it is compulsory
- source document and effective statement

Do not use “latest scheme” as a universal rule. A student's progress must be evaluated against the scheme applicable to that student's admission cohort.

## Requirement types

### Overall and component thresholds

Capture:

- total graduation units
- university-core units and subcategories
- school-package units
- total major units
- required-course units
- elective units
- free-elective units
- capstone, internship, exchange, or residency requirements

Store the printed total and the independently calculated total when both are available.

### Mandatory groups

Represent each requirement as alternatives of complete combinations:

```json
{
  "id": "programming-foundation",
  "alternatives": [
    ["CSC1001", "CSC1002"],
    ["CSC1003", "CSC1004"]
  ],
  "sourceEvidence": "Students can choose either CSC1001 and CSC1002 or CSC1003 and CSC1004."
}
```

A single compulsory course is one alternative containing one code. “MAT1001 or MAT1011” is two one-course alternatives. Never split an AND-combination into independent any-one choices.

### Elective and selection rules

For every pool or category, capture:

- identifier and displayed label
- exact course list or allowed scope
- required units, required course count, or range
- minimum or maximum contribution
- level restrictions
- breadth and depth constraints
- whether the pool counts toward stream depth
- whether external or approved courses may count

Examples seen in the project include:

- at least 12 or 16 units from Group A
- courses from at least three elective areas
- at least three courses in one area or stream
- at most two 2000-level electives
- complementary electives that count toward units but not stream depth

### Streams and concentrations

Record whether selection is:

- compulsory at admission,
- compulsory before graduation,
- optional for display only, or
- unknown and awaiting confirmation.

Do not enforce an optional declaration as a graduation blocker. If streams have different required courses, create separate variants or explicit conditional branches.

### Special conditions

Model these as first-class conditions with evidence:

- course equivalence or renamed codes
- exemption triggered by another completed course
- approved substitution up to a unit limit
- transfer or exchange courses
- exclusions and mutually exclusive courses
- double-counting restrictions
- honours/non-honours alternatives
- “and thereafter” applicability
- capstone sequencing or prerequisites only when explicitly part of graduation eligibility

## Suggested JSON draft

```json
{
  "programmeKey": "cse",
  "programme": "Computer Science and Engineering",
  "cohort": {"from": 2024, "to": null},
  "stream": null,
  "source": {"file": "...pdf", "pages": [1, 2]},
  "status": "needs_review",
  "totals": {"majorUnits": 70},
  "mandatoryGroups": [],
  "electiveCategories": [],
  "constraints": {
    "minUnitsByCategory": [],
    "maxLevelCourses": [],
    "breadth": null,
    "depth": null,
    "streamDeclaration": null,
    "exactMajorPool": true
  },
  "specialConditions": [],
  "cohortDifferences": [],
  "issues": []
}
```

Extend the schema when the source requires a new semantic. Do not force a complex academic rule into an inaccurate existing field.

## Human-review record

For each programme/cohort, report:

1. source and applicability;
2. interpreted totals and components;
3. mandatory groups and compound alternatives;
4. elective categories and thresholds;
5. stream/concentration logic;
6. special conditions and footnotes;
7. differences from the previous cohort;
8. unresolved issues;
9. reviewer and approval status.

## Validation cases for the programmed engine

Create at least these cases:

- all requirements exactly satisfied;
- one compulsory course missing;
- each branch of an alternative combination;
- total elective units met but a category minimum missed;
- breadth met but depth missed, and vice versa;
- a course eligible for two categories to test non-double-counting;
- maximum-level rule exceeded;
- optional versus declared stream;
- student on the boundary between two cohort variants.
