CREATE TABLE goals (
  programme TEXT,
  goal_id TEXT,
  name TEXT,
  parent_goal_id TEXT,
  goal_type TEXT,
  definition TEXT,
  horizon_months INTEGER,
  assessment_methods TEXT,
  success_criteria TEXT,
  source TEXT,
  status TEXT,
  PRIMARY KEY (goal_id)
);

CREATE TABLE skills (
  programme TEXT,
  skill_id TEXT,
  name TEXT,
  description TEXT,
  skill_type TEXT,
  assessment_type TEXT,
  source TEXT,
  status TEXT,
  roadmap_topics TEXT,
  roadmap_source TEXT,
  parent_skill_id TEXT,
  PRIMARY KEY (skill_id)
);

CREATE TABLE modules (
  programme TEXT,
  module_id TEXT,
  course_id TEXT,
  sequence INTEGER,
  name TEXT,
  topics TEXT,
  lecture_hours INTEGER,
  source TEXT,
  status TEXT,
  group_in_source TEXT,
  duration_note TEXT,
  PRIMARY KEY (module_id)
);

CREATE TABLE courses (
  programme TEXT,
  course_id TEXT,
  name TEXT,
  course_no TEXT,
  level INTEGER,
  category TEXT,
  type_in_source TEXT,
  l_t_p TEXT,
  credits NUMERIC,
  lecture_hours INTEGER,
  offered_for TEXT,
  prerequisite_text TEXT,
  antirequisite_text TEXT,
  source TEXT,
  status TEXT,
  department TEXT,
  semester_regular_btech TEXT,
  stream_or_specialization TEXT,
  description TEXT,
  PRIMARY KEY (course_id)
);

CREATE TABLE goal_skill (
  programme TEXT,
  goal_id TEXT,
  skill_id TEXT,
  priority TEXT,
  target_level TEXT,
  weight TEXT,
  source TEXT,
  status TEXT,
  PRIMARY KEY (goal_id, skill_id)
);

CREATE TABLE module_skill (
  programme TEXT,
  module_id TEXT,
  skill_id TEXT,
  source TEXT,
  status TEXT,
  PRIMARY KEY (module_id, skill_id)
);

CREATE TABLE institute_resources (
  resource_id TEXT,
  programme TEXT,
  course_id TEXT,
  resource_type TEXT,
  title TEXT,
  year_of_study INTEGER,
  academic_year TEXT,
  semester TEXT,
  exam_date TEXT,
  max_marks INTEGER,
  duration_min INTEGER,
  question_count INTEGER,
  module_ids TEXT,
  skill_ids TEXT,
  topics TEXT,
  format TEXT,
  drive_url TEXT,
  licence TEXT,
  source TEXT,
  status TEXT,
  PRIMARY KEY (resource_id)
);

CREATE TABLE external_resources (
  programme TEXT,
  resource_id TEXT,
  skill_id TEXT,
  title TEXT,
  provider TEXT,
  resource_type TEXT,
  url TEXT,
  no_institute_course TEXT,
  source TEXT,
  status TEXT,
  role TEXT,
  stage TEXT,
  sequence INTEGER,
  access TEXT,
  notes TEXT,
  PRIMARY KEY (resource_id, skill_id)
);

CREATE TABLE question_bank (
  problem_name TEXT,
  row_type TEXT,
  title TEXT,
  body_text TEXT,
  answer TEXT,
  answer_type TEXT,
  hint_id TEXT,
  dependency TEXT,
  mc_choices TEXT,
  images TEXT,
  parent TEXT,
  resource_id TEXT,
  programme TEXT,
  course_id TEXT,
  module_ids TEXT,
  skill_ids TEXT,
  kc TEXT,
  marks NUMERIC,
  question_type TEXT,
  cognitive_level TEXT,
  difficulty TEXT,
  source TEXT,
  status TEXT,
  sub_part_count INTEGER,
  PRIMARY KEY (problem_name)
);

CREATE TABLE faculty (
  faculty_id TEXT,
  name TEXT,
  programme TEXT,
  department TEXT,
  designation TEXT,
  specializations TEXT,
  projects_grants TEXT,
  source_url TEXT,
  data_status TEXT,
  retrieved_on TEXT,
  email TEXT,
  phd_qualification TEXT,
  phone TEXT,
  PRIMARY KEY (faculty_id)
);

CREATE TABLE faculty_course (
  faculty_id TEXT,
  programme TEXT,
  course_id TEXT,
  relation TEXT,
  evidence_url TEXT,
  note TEXT,
  PRIMARY KEY (faculty_id, course_id, relation)
);

CREATE TABLE skill_overlaps (
  software_skill_id TEXT,
  chemical_engineering_skill_id TEXT,
  why_they_overlap TEXT,
  suggested_action TEXT,
  decision TEXT,
  note TEXT,
  PRIMARY KEY (software_skill_id, chemical_engineering_skill_id)
);

CREATE TABLE prerequisites (
  programme TEXT,
  course_id TEXT,
  requires_course_id TEXT,
  requires_text TEXT,
  any_of_group TEXT,
  source TEXT,
  status TEXT,
  PRIMARY KEY (programme, course_id, requires_text)
);

CREATE TABLE skill_faculty (
  programme TEXT,
  skill_id TEXT,
  skill_name TEXT,
  recommended_faculty TEXT,
  faculty_count INTEGER,
  PRIMARY KEY (programme, skill_id)
);

CREATE TABLE resource_coverage (
  course_id TEXT,
  papers TEXT,
  quizzes TEXT,
  minors TEXT,
  majors TEXT,
  type_unclassified TEXT,
  problems_detected_by_ocr TEXT,
  sub_parts_merged_into_problems TEXT,
  problems_linked_to_modules TEXT,
  integrity_checks TEXT,
  PRIMARY KEY (course_id)
);

CREATE TABLE skill_course_sheet (
  programme TEXT,
  skill_id TEXT,
  skill_name TEXT,
  course_id TEXT,
  course_name TEXT,
  modules_covering TEXT,
  lecture_hours_covering TEXT,
  source TEXT,
  relevance TEXT,
  stage TEXT,
  status TEXT,
  PRIMARY KEY (programme, skill_id, course_name)
);
