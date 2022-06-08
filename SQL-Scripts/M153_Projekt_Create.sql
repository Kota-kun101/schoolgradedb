/* Database creation */
USE master;
DROP DATABASE IF EXISTS [schoolgradedb];
CREATE DATABASE [schoolgradedb];
GO
USE [schoolgradedb];

GO
-- Create Tables
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

/* Function, Procedure and Trigger creation */
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
			RAISERROR ( 'The grade must be in between 1 and 6.',11,1);
			DELETE FROM Grades WHERE id = @gradeId
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