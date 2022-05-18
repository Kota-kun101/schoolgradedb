USE master;
DROP DATABASE IF EXISTS [schoolgradedb]
CREATE DATABASE [schoolgradedb];
USE [schoolgradedb];

CREATE TABLE Students(
    [id] INT NOT NULL IDENTITY PRIMARY KEY,
    [firstname] VARCHAR(255) NOT NULL,
    [lastname] VARCHAR(255) NOT NULL,
    [birthdate] DATE NOT NULL,
    [fk_classId] INT NOT NULL
);

CREATE TABLE Schools(
    [id] INT NOT NULL IDENTITY PRIMARY KEY,
    [name] VARCHAR(255) NOT NULL
);

CREATE TABLE Subjects(
    [id] INT NOT NULL IDENTITY PRIMARY KEY,
    [name] VARCHAR(255) NOT NULL,
    [weight] FLOAT NOT NULL
);

CREATE TABLE Grades(
    [id] INT NOT NULL IDENTITY PRIMARY KEY,
    [grade] FLOAT NOT NULL,
    [fk_studentId] INT NOT NULL,
    [fk_examId] INT NOT NULL
);

CREATE TABLE Classes(
    [id] INT NOT NULL IDENTITY PRIMARY KEY,
    [name] VARCHAR(255) NOT NULL,
    [fk_schoolId] INT NOT NULL
);

CREATE TABLE Exams(
    [id] INT NOT NULL IDENTITY PRIMARY KEY,
    [topic] INT NOT NULL,
    [weight] FLOAT NOT NULL,
    [fk_subjectId] INT NOT NULL
);

CREATE TABLE Exams_to_Classes(
    [id] INT NOT NULL IDENTITY PRIMARY KEY,
    [fk_examId] INT NOT NULL,
    [fk_classId] INT NOT NULL,
    [avgGrade] FLOAT NOT NULL
);
ALTER TABLE
    Students ADD CONSTRAINT [students_fk_classid_foreign] FOREIGN KEY([fk_classId]) REFERENCES Classes([id]);
ALTER TABLE
    Classes ADD CONSTRAINT [classes_fk_schoolid_foreign] FOREIGN KEY([fk_schoolId]) REFERENCES Schools([id]);
ALTER TABLE
    Grades ADD CONSTRAINT [grades_fk_examid_foreign] FOREIGN KEY([fk_examId]) REFERENCES Exams([id]);
ALTER TABLE
    Grades ADD CONSTRAINT [grades_fk_studentid_foreign] FOREIGN KEY([fk_studentId]) REFERENCES Students([id]);
ALTER TABLE
    Exams ADD CONSTRAINT [exams_fk_subjectid_foreign] FOREIGN KEY([fk_subjectId]) REFERENCES Subjects([id]);
ALTER TABLE
    Exams_to_Classes ADD CONSTRAINT [exams_to_classes_fk_examid_foreign] FOREIGN KEY([fk_examId]) REFERENCES Exams([id]);
ALTER TABLE
    Exams_to_Classes ADD CONSTRAINT [exams_to_classes_fk_classid_foreign] FOREIGN KEY([fk_classId]) REFERENCES Classes([id]);

-- Insert into schools-Table
INSERT INTO Schools (name) VALUES
('BBZW Sursee'),
('BBZW Emmen')

-- Insert into classes-Table
INSERT INTO Classes (name, fk_schoolId) VALUES
('INF19aL', 1),
('INF19bL', 1),
('BMLT20A', 2),
('BMLT20B', 2)

-- Insert into subjects-Table
INSERT INTO Subjects (name, weight) VALUES
('Deutsch', 1.0),
('Französisch', 0.5),
('Englisch', 1.0),
('Mathematik', 2.0);

-- Insert into exams-Table
INSERT INTO Exams (topic, weight, fk_subjectId) VALUES
('Erörterung', 2.0, 1),
('Gedichtinterpretation', 1.0, 1),
('Satzbau', 1.0, 1),
('Wanderdiktat', 0.5, 1),
('Voci Unité 1', 0.5, 2),
('Unité 1', 1, 2),
('Voci Unité 2', 0.5, 2),
('Unité 2', 1, 2),
('Vocabulary Unite 12', 0.5, 3),
('Unite 12', 1, 3),
('Vocabulary Unite 13', 0.5, 3),
('Unite 13', 1, 3),
('Geometrie', 0.75, 4),
('Logarithmen', 1.5, 4),
('Stereometrie', 2.0, 4),
('Algebra', 3.0, 4);

-- Insert into grades-Table
INSERT INTO Grades (grade, fk_studentId, fk_examId) VALUES
(6, 1, 1),
(5, 2, 1),
(3.5, 3, 1),
(4, 4, 1),
(4.2, 5, 1),
(4.6, 6, 1),
(5.7, 7, 1),
(5.1, 8, 1),
(4.6, 9, 1),
(2.3, 10, 1),
(5.4, 1, 2),
(4.6, 2, 2),
(4.2, 3, 2),
(3.6, 4, 2),
(5.3, 5, 2),
(4.5, 6, 2),
(5.2, 12, 2),
(4.9, 13, 2),
(3.4, 14, 2),
(3.6, 15, 2),
(3.9, 16, 2),
(4.3, 17, 2),
(5.4, 18, 2)