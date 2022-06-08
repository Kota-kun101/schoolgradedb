USE master;
DROP DATABASE IF EXISTS [schoolgradedb];
CREATE DATABASE [schoolgradedb];
USE [schoolgradedb];

GO

-- Crate Tables
CREATE TABLE Students(
    [id] INT NOT NULL IDENTITY PRIMARY KEY,
    [firstname] VARCHAR(255) NOT NULL,
    [lastname] VARCHAR(255) NOT NULL,
    [birthdate] DATE NOT NULL,
	[isActive] BINARY NOT NULL DEFAULT 1,
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
    [topic] VARCHAR(30) NOT NULL,
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

GO

-- Create Function, Trigger and Procedure
CREATE FUNCTION CalcStudentAvgGrade (@StudentId Integer)
	RETURNS FLOAT
AS
BEGIN
	RETURN (SELECT ROUND(SUM(s.weight*e.weight*g.grade)/SUM(s.weight*e.weight), 1) FROM Grades g
	JOIN Exams e ON g.fk_examId = e.id
	JOIN Subjects s ON e.fk_subjectId = s.id
	WHERE fk_studentId = @StudentId)
END

GO

CREATE PROCEDURE CalcClassStudentAvg
	@classId INT
AS
	SELECT firstname + ' ' + lastname AS 'Name', [dbo].CalcStudentAvgGrade(id) AS 'Durchschnitt' FROM Students
	WHERE fk_classId = @classId
	UNION
	SELECT 'Klassenschnitt', ROUND(AVG([dbo].CalcStudentAvgGrade(id)), 1) FROM  Students
	WHERE fk_classId = @classId
	GROUP BY fk_classId
GO

CREATE TRIGGER CalcAvgGradeOfClasses on Grades
	for INSERT, UPDATE
AS
	DECLARE @gradeId INT;
	DECLARE @MyCursor CURSOR;
	set @MyCursor = CURSOR FOR (SELECT id FROM inserted)

	OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @gradeId

	IF (SELECT COUNT(*) FROM inserted)=0 
	BEGIN
		PRINT 'class or student does not exist';
	END

	WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @grade FLOAT = (SELECT grade FROM Grades WHERE id = @gradeId)
		IF @grade > 6 OR @grade < 1
		BEGIN
			PRINT 'The grade ' + LTRIM(STR(@grade)) + ' is invalid! It must be in between 1 and 6.'
		END
		ELSE
		BEGIN
			DECLARE @examId INT
			DECLARE @classId INT
			DECLARE @avg FLOAT

			SET @examId = (SELECT fk_examId FROM Grades WHERE id = @gradeId)
			SET @classId = (SELECT fk_classId FROM Students WHERE id IN (SELECT fk_studentId FROM Grades WHERE id = @gradeId))

			SET @avg = (SELECT ROUND(AVG(grade), 1) FROM Grades g
			WHERE g.fk_studentId IN (SELECT id FROM Students WHERE fk_classId = @classId) AND g.fk_examId = @examId)

			IF (SELECT COUNT(*) FROM Exams_to_Classes WHERE fk_classId = @classId AND fk_examId = @examId) = 0
			BEGIN
				INSERT INTO Exams_to_Classes (fk_examId, fk_classId, avgGrade) VALUES (@examId, @classId, @avg)
			END
			ELSE
			BEGIN
				UPDATE Exams_to_Classes SET avgGrade = @avg WHERE fk_examId = @examId AND fk_classId = @classId
			END
		END

		FETCH NEXT FROM @MyCursor 
		INTO @gradeId 
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
GO


-- Insert Data
INSERT INTO Schools (name) VALUES
('BBZW Sursee'),
('BBZW Emmen')

INSERT INTO Classes (name, fk_schoolId) VALUES
('INF19aL', 1),
('INF19bL', 1),
('BMLT20A', 2),
('BMLT20B', 2)

INSERT INTO Subjects (name, weight) VALUES
('Deutsch', 1.0),
('Franz�sisch', 0.5),
('Englisch', 1.0),
('Mathematik', 2.0);

INSERT INTO Exams (topic, weight, fk_subjectId) VALUES
('Er�rterung', 2.0, 1),
('Gedichtinterpretation', 1.0, 1),
('Satzbau', 1.0, 1),
('Wanderdiktat', 0.5, 1),
('Voci Unit� 1', 0.5, 2),
('Unit� 1', 1, 2),
('Voci Unit� 2', 0.5, 2),
('Unit� 2', 1, 2),
('Vocabulary Unite 12', 0.5, 3),
('Unite 12', 1, 3),
('Vocabulary Unite 13', 0.5, 3),
('Unite 13', 1, 3),
('Geometrie', 0.75, 4),
('Logarithmen', 1.5, 4),
('Stereometrie', 2.0, 4),
('Algebra', 3.0, 4);

INSERT INTO Students (firstname, lastname, birthdate, fk_classId) VALUES
('Osian', 'Benson', '2004-12-13', 1),
('Franz', 'Müller', '2004-12-13', 1),
('Florian', 'Goller', '2004-12-13', 1),
('Jan', 'Fischer', '2004-12-13', 1),
('Kota', 'Schnider', '2004-12-13', 1),
('Manuel', 'Marbacher', '2004-12-13', 2),
('Lian', 'Aeschlimann', '2004-12-13', 2),
('Alex', 'Kina', '2004-12-13', 2),
('Fabian', 'Müller', '2004-12-13', 2),
('Erin', 'Bachmann', '2004-12-13', 2),
('Joshua', 'Odermatt', '2004-12-13', 3),
('Moritz', 'Rast', '2004-12-13', 3),
('Dario', 'Hollbach', '2004-12-13', 3),
('Laurin', 'Lötscher', '2004-12-13', 3),
('Nicola', 'Fioretti', '2004-12-13', 3),
('Lana', 'Rhodes', '2004-12-13', 4),
('Mia', 'Khalifa', '2004-12-13', 4),
('Johnny', 'Sins', '2004-12-13', 4),
('Peter', 'Kaufmann', '2004-12-13', 4),
('Silvan', 'Heini', '2004-12-13', 4)

-- generated with python 3
/*
import random
for i in range(1, 21):
    for j in range(1, 17):
        int_num = random.choice(range(1, 10))
        float_num = int_num/10 + random.choice(range(1, 6))
        print("(" + str(float_num) + ", " + str(i) + ", " + str(j) + " ),") 
*/
INSERT INTO Grades (grade, fk_studentId, fk_examId) VALUES
(2.8, 1, 1 ),
(3.1, 1, 2 ),
(2.6, 1, 3 ),
(2.4, 1, 4 ),
(1.9, 1, 5 ),
(3.7, 1, 6 ),
(1.8, 1, 7 ),
(1.3, 1, 8 ),
(1.4, 1, 9 ),
(5.5, 1, 10 ),
(3.9, 1, 11 ),
(4.9, 1, 12 ),
(5.2, 1, 13 ),
(5.3, 1, 14 ),
(3.6, 1, 15 ),
(5.6, 1, 16 ),
(1.2, 2, 1 ),
(4.7, 2, 2 ),
(4.6, 2, 3 ),
(3.1, 2, 4 ),
(4.7, 2, 5 ),
(1.7, 2, 6 ),
(1.4, 2, 7 ),
(5.1, 2, 8 ),
(5.5, 2, 9 ),
(1.9, 2, 10 ),
(3.8, 2, 11 ),
(3.4, 2, 12 ),
(4.5, 2, 13 ),
(5.7, 2, 14 ),
(2.3, 2, 15 ),
(4.1, 2, 16 ),
(2.9, 3, 1 ),
(2.4, 3, 2 ),
(4.1, 3, 3 ),
(4.6, 3, 4 ),
(5.2, 3, 5 ),
(3.1, 3, 6 ),
(5.2, 3, 7 ),
(4.2, 3, 8 ),
(1.8, 3, 9 ),
(2.8, 3, 10 ),
(1.9, 3, 11 ),
(3.5, 3, 12 ),
(5.9, 3, 13 ),
(3.2, 3, 14 ),
(2.5, 3, 15 ),
(1.5, 3, 16 ),
(2.3, 4, 1 ),
(3.4, 4, 2 ),
(5.2, 4, 3 ),
(4.5, 4, 4 ),
(3.3, 4, 5 ),
(5.4, 4, 6 ),
(2.7, 4, 7 ),
(5.1, 4, 8 ),
(4.1, 4, 9 ),
(4.4, 4, 10 ),
(2.9, 4, 11 ),
(4.5, 4, 12 ),
(4.5, 4, 13 ),
(4.9, 4, 14 ),
(1.6, 4, 15 ),
(4.1, 4, 16 ),
(1.2, 5, 1 ),
(3.4, 5, 2 ),
(5.1, 5, 3 ),
(3.7, 5, 4 ),
(4.2, 5, 5 ),
(2.6, 5, 6 ),
(3.8, 5, 7 ),
(5.7, 5, 8 ),
(1.9, 5, 9 ),
(3.8, 5, 10 ),
(4.8, 5, 11 ),
(5.7, 5, 12 ),
(3.6, 5, 13 ),
(4.4, 5, 14 ),
(1.7, 5, 15 ),
(2.5, 5, 16 ),
(2.1, 6, 1 ),
(2.6, 6, 2 ),
(1.9, 6, 3 ),
(4.1, 6, 4 ),
(2.3, 6, 5 ),
(1.6, 6, 6 ),
(1.9, 6, 7 ),
(5.3, 6, 8 ),
(1.6, 6, 9 ),
(1.6, 6, 10 ),
(2.4, 6, 11 ),
(4.8, 6, 12 ),
(5.1, 6, 13 ),
(2.6, 6, 14 ),
(3.5, 6, 15 ),
(4.6, 6, 16 ),
(3.2, 7, 1 ),
(1.5, 7, 2 ),
(3.5, 7, 3 ),
(3.1, 7, 4 ),
(3.5, 7, 5 ),
(2.2, 7, 6 ),
(4.9, 7, 7 ),
(1.5, 7, 8 ),
(1.1, 7, 9 ),
(2.7, 7, 10 ),
(1.5, 7, 11 ),
(3.4, 7, 12 ),
(4.7, 7, 13 ),
(4.6, 7, 14 ),
(1.2, 7, 15 ),
(3.1, 7, 16 ),
(5.6, 8, 1 ),
(3.3, 8, 2 ),
(4.6, 8, 3 ),
(5.8, 8, 4 ),
(1.5, 8, 5 ),
(5.5, 8, 6 ),
(1.4, 8, 7 ),
(2.4, 8, 8 ),
(4.3, 8, 9 ),
(4.4, 8, 10 ),
(3.6, 8, 11 ),
(1.7, 8, 12 ),
(2.5, 8, 13 ),
(2.6, 8, 14 ),
(1.5, 8, 15 ),
(2.4, 8, 16 ),
(5.8, 9, 1 ),
(5.4, 9, 2 ),
(3.5, 9, 3 ),
(5.7, 9, 4 ),
(3.4, 9, 5 ),
(3.3, 9, 6 ),
(1.2, 9, 7 ),
(3.7, 9, 8 ),
(3.8, 9, 9 ),
(2.6, 9, 10 ),
(3.5, 9, 11 ),
(1.1, 9, 12 ),
(5.5, 9, 13 ),
(3.3, 9, 14 ),
(4.7, 9, 15 ),
(3.3, 9, 16 ),
(3.2, 10, 1 ),
(3.9, 10, 2 ),
(3.2, 10, 3 ),
(1.4, 10, 4 ),
(5.5, 10, 5 ),
(1.8, 10, 6 ),
(4.7, 10, 7 ),
(4.1, 10, 8 ),
(1.4, 10, 9 ),
(3.6, 10, 10 ),
(3.4, 10, 11 ),
(5.7, 10, 12 ),
(2.8, 10, 13 ),
(1.1, 10, 14 ),
(3.1, 10, 15 ),
(3.4, 10, 16 ),
(1.9, 11, 1 ),
(3.5, 11, 2 ),
(4.4, 11, 3 ),
(3.8, 11, 4 ),
(2.3, 11, 5 ),
(2.8, 11, 6 ),
(1.9, 11, 7 ),
(1.1, 11, 8 ),
(4.9, 11, 9 ),
(2.3, 11, 10 ),
(3.2, 11, 11 ),
(5.1, 11, 12 ),
(2.7, 11, 13 ),
(4.7, 11, 14 ),
(1.5, 11, 15 ),
(4.4, 11, 16 ),
(3.6, 12, 1 ),
(2.4, 12, 2 ),
(3.6, 12, 3 ),
(2.4, 12, 4 ),
(3.4, 12, 5 ),
(3.3, 12, 6 ),
(3.2, 12, 7 ),
(1.1, 12, 8 ),
(4.7, 12, 9 ),
(3.2, 12, 10 ),
(4.3, 12, 11 ),
(5.4, 12, 12 ),
(3.4, 12, 13 ),
(5.1, 12, 14 ),
(3.2, 12, 15 ),
(1.8, 12, 16 ),
(3.5, 13, 1 ),
(4.8, 13, 2 ),
(3.3, 13, 3 ),
(5.9, 13, 4 ),
(1.9, 13, 5 ),
(5.6, 13, 6 ),
(3.1, 13, 7 ),
(1.3, 13, 8 ),
(1.7, 13, 9 ),
(1.1, 13, 10 ),
(3.1, 13, 11 ),
(1.3, 13, 12 ),
(4.2, 13, 13 ),
(4.9, 13, 14 ),
(2.1, 13, 15 ),
(4.3, 13, 16 ),
(5.3, 14, 1 ),
(2.6, 14, 2 ),
(5.6, 14, 3 ),
(1.2, 14, 4 ),
(2.3, 14, 5 ),
(2.7, 14, 6 ),
(2.2, 14, 7 ),
(3.5, 14, 8 ),
(1.8, 14, 9 ),
(5.1, 14, 10 ),
(5.1, 14, 11 ),
(3.6, 14, 12 ),
(3.8, 14, 13 ),
(3.9, 14, 14 ),
(5.1, 14, 15 ),
(2.2, 14, 16 ),
(2.3, 15, 1 ),
(1.1, 15, 2 ),
(3.3, 15, 3 ),
(3.7, 15, 4 ),
(2.7, 15, 5 ),
(5.7, 15, 6 ),
(2.9, 15, 7 ),
(2.9, 15, 8 ),
(3.7, 15, 9 ),
(5.2, 15, 10 ),
(5.5, 15, 11 ),
(4.4, 15, 12 ),
(1.2, 15, 13 ),
(2.4, 15, 14 ),
(1.1, 15, 15 ),
(4.1, 15, 16 ),
(2.8, 16, 1 ),
(5.5, 16, 2 ),
(2.1, 16, 3 ),
(3.4, 16, 4 ),
(1.6, 16, 5 ),
(5.6, 16, 6 ),
(1.5, 16, 7 ),
(5.1, 16, 8 ),
(5.5, 16, 9 ),
(4.9, 16, 10 ),
(1.5, 16, 11 ),
(4.2, 16, 12 ),
(4.3, 16, 13 ),
(2.9, 16, 14 ),
(4.3, 16, 15 ),
(3.9, 16, 16 ),
(4.6, 17, 1 ),
(2.1, 17, 2 ),
(4.8, 17, 3 ),
(4.6, 17, 4 ),
(4.5, 17, 5 ),
(2.8, 17, 6 ),
(2.7, 17, 7 ),
(3.2, 17, 8 ),
(1.8, 17, 9 ),
(3.1, 17, 10 ),
(5.4, 17, 11 ),
(5.8, 17, 12 ),
(1.8, 17, 13 ),
(5.9, 17, 14 ),
(5.4, 17, 15 ),
(3.5, 17, 16 ),
(2.2, 18, 1 ),
(4.3, 18, 2 ),
(4.7, 18, 3 ),
(4.7, 18, 4 ),
(5.1, 18, 5 ),
(4.8, 18, 6 ),
(4.4, 18, 7 ),
(5.6, 18, 8 ),
(5.3, 18, 9 ),
(4.8, 18, 10 ),
(5.4, 18, 11 ),
(4.9, 18, 12 ),
(4.8, 18, 13 ),
(4.9, 18, 14 ),
(5.7, 18, 15 ),
(3.2, 18, 16 ),
(4, 19, 1 ),
(6, 19, 2 ),
(6, 19, 3 ),
(6, 19, 4 ),
(6, 19, 5 ),
(6, 19, 6 ),
(6, 19, 7 ),
(6, 19, 8 ),
(6, 19, 9 ),
(6, 19, 10 ),
(6, 19, 11 ),
(6, 19, 12 ),
(6, 19, 13 ),
(6, 19, 14 ),
(6, 19, 15 ),
(6, 19, 16 ),
(1.9, 20, 1 ),
(3.8, 20, 2 ),
(3.7, 20, 3 ),
(3.3, 20, 4 ),
(5.8, 20, 5 ),
(3.1, 20, 6 ),
(4.4, 20, 7 ),
(5.3, 20, 8 ),
(4.9, 20, 9 ),
(5.8, 20, 10 ),
(5.9, 20, 11 ),
(3.4, 20, 12 ),
(1.7, 20, 13 ),
(4.2, 20, 14 ),
(5.9, 20, 15 ),
(4.4, 20, 16 ),
(0, 20, 16) -- Invalid query

EXEC CalcClassStudentAvg @classId = 1
EXEC CalcClassStudentAvg @classId = 4

DECLARE @id int = (SELECT id FROM Students WHERE firstname = 'Peter' and lastname = 'Kaufmann')

UPDATE Grades SET grade = 6 WHERE fk_studentId = @id AND fk_examId = 1
UPDATE Grades SET grade = 2 WHERE fk_studentId = @id AND fk_examId = 100 -- Invalid query

SELECT [dbo].CalcStudentAvgGrade(@id) AS 'Average Grade from Kaufmann Peter'
