USE schoolgradedb;

/* Executions */
EXEC CalcClassStudentAvg @classId = 1
EXEC CalcClassStudentAvg @classId = 4

DECLARE @id int = (SELECT id FROM Students WHERE firstname = 'Peter' and lastname = 'Kaufmann')

UPDATE Grades SET grade = 6 WHERE fk_studentId = @id AND fk_examId = 1
UPDATE Grades SET grade = 2 WHERE fk_studentId = @id AND fk_examId = 100 -- Invalid query
UPDATE Grades SET grade = 7 WHERE fk_studentId = @id AND fk_examId = 1 -- Invalid query
UPDATE Grades SET grade = 0 WHERE fk_studentId = @id AND fk_examId = 1 -- Invalid query

SELECT [dbo].CalcStudentAvgGrade(@id) AS 'Average Grade from Kaufmann Peter'
