DROP TRIGGER test;
CREATE TRIGGER test on Grades
	for INSERT, UPDATE
AS
	DECLARE @gradeId INT;
	DECLARE @MyCursor CURSOR;
	SELECT id FROM inserted
	set @MyCursor = CURSOR FOR (SELECT id FROM inserted)

	OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @gradeId

	WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @examId INT
		DECLARE @classId INT
		DECLARE @avg FLOAT

		SET @examId = (SELECT fk_examId FROM Grades WHERE id = @gradeId)
		SET @classId = (SELECT fk_classId FROM Students WHERE id IN (SELECT fk_studentId FROM Grades WHERE id = @gradeId))

		SET @avg = (SELECT AVG(grade) FROM Grades g
		WHERE g.fk_studentId IN (SELECT id FROM Students WHERE fk_classId = @classId) AND g.fk_examId = @examId)

		IF (SELECT COUNT(*) FROM Exams_to_Classes WHERE fk_classId = @classId AND fk_examId = @examId) = 0
		BEGIN
			INSERT INTO Exams_to_Classes (fk_examId, fk_classId, avgGrade) VALUES (@examId, @classId, @avg)
		END
		ELSE
		BEGIN
			UPDATE Exams_to_Classes SET avgGrade = @avg WHERE fk_examId = @examId AND fk_classId = @classId
		END

		FETCH NEXT FROM @MyCursor 
		INTO @gradeId 
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
GO