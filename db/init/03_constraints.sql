CREATE EXTENSION IF NOT EXISTS pg_trgm;

ALTER TABLE goals ADD FOREIGN KEY (parent_goal_id) REFERENCES goals(goal_id);
ALTER TABLE skills ADD FOREIGN KEY (parent_skill_id) REFERENCES skills(skill_id);
ALTER TABLE modules ADD FOREIGN KEY (course_id) REFERENCES courses(course_id);
ALTER TABLE goal_skill ADD FOREIGN KEY (goal_id) REFERENCES goals(goal_id);
ALTER TABLE goal_skill ADD FOREIGN KEY (skill_id) REFERENCES skills(skill_id);
ALTER TABLE module_skill ADD FOREIGN KEY (module_id) REFERENCES modules(module_id);
ALTER TABLE module_skill ADD FOREIGN KEY (skill_id) REFERENCES skills(skill_id);
ALTER TABLE external_resources ADD FOREIGN KEY (skill_id) REFERENCES skills(skill_id);
ALTER TABLE question_bank ADD FOREIGN KEY (parent) REFERENCES question_bank(problem_name);
ALTER TABLE question_bank ADD FOREIGN KEY (resource_id) REFERENCES institute_resources(resource_id);
ALTER TABLE faculty_course ADD FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id);

CREATE INDEX ON modules(course_id);
CREATE INDEX ON goal_skill(skill_id);
CREATE INDEX ON module_skill(skill_id);
CREATE INDEX ON external_resources(skill_id);
CREATE INDEX ON question_bank(parent);
CREATE INDEX ON question_bank(resource_id);
CREATE INDEX ON goals USING gin ((name || ' ' || coalesce(definition,'')) gin_trgm_ops);

CREATE VIEW skill_course AS
SELECT DISTINCT s.skill_id, s.name AS skill_name, c.course_id, c.name AS course_name
FROM courses c JOIN modules m ON m.course_id = c.course_id
JOIN module_skill ms ON ms.module_id = m.module_id
JOIN skills s ON s.skill_id = ms.skill_id;

ALTER TABLE skill_overlaps ADD FOREIGN KEY (software_skill_id) REFERENCES skills(skill_id);
ALTER TABLE skill_overlaps ADD FOREIGN KEY (chemical_engineering_skill_id) REFERENCES skills(skill_id);
ALTER TABLE prerequisites ADD FOREIGN KEY (course_id) REFERENCES courses(course_id);
ALTER TABLE prerequisites ADD FOREIGN KEY (requires_course_id) REFERENCES courses(course_id);
ALTER TABLE skill_faculty ADD FOREIGN KEY (skill_id) REFERENCES skills(skill_id);
ALTER TABLE skill_course_sheet ADD FOREIGN KEY (skill_id) REFERENCES skills(skill_id);
ALTER TABLE skill_course_sheet ADD FOREIGN KEY (course_id) REFERENCES courses(course_id);
