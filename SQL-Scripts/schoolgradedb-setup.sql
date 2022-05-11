CREATE TABLE `Students`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `firstname` VARCHAR(255) NOT NULL,
    `lastname` VARCHAR(255) NOT NULL,
    `birthdate` DATE NOT NULL,
    `fk_classId` INT NOT NULL
);
CREATE TABLE `Schools`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL
);
CREATE TABLE `Subjects`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `weight` DOUBLE(8, 2) NOT NULL
);
CREATE TABLE `Grades`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `grade` DOUBLE(8, 2) NOT NULL,
    `fk_studentId` INT NOT NULL,
    `fk_examId` INT NOT NULL
);
CREATE TABLE `Classes`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `fk_schoolId` INT NOT NULL
);
CREATE TABLE `Exams`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `topic` INT NOT NULL,
    `weight` DOUBLE(8, 2) NOT NULL,
    `fk_subjectId` INT NOT NULL
);
CREATE TABLE `Exams_to_Classes`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `fk_examId` INT NOT NULL,
    `fk_classId` INT NOT NULL,
    `avgGrade` DOUBLE(8, 2) NOT NULL
);
ALTER TABLE
    `Students` ADD CONSTRAINT `students_fk_classid_foreign` FOREIGN KEY(`fk_classId`) REFERENCES `Classes`(`id`);
ALTER TABLE
    `Classes` ADD CONSTRAINT `classes_fk_schoolid_foreign` FOREIGN KEY(`fk_schoolId`) REFERENCES `Schools`(`id`);
ALTER TABLE
    `Grades` ADD CONSTRAINT `grades_fk_examid_foreign` FOREIGN KEY(`fk_examId`) REFERENCES `Exams`(`id`);
ALTER TABLE
    `Grades` ADD CONSTRAINT `grades_fk_studentid_foreign` FOREIGN KEY(`fk_studentId`) REFERENCES `Students`(`id`);
ALTER TABLE
    `Exams` ADD CONSTRAINT `exams_fk_subjectid_foreign` FOREIGN KEY(`fk_subjectId`) REFERENCES `Subjects`(`id`);
ALTER TABLE
    `Exams_to_Classes` ADD CONSTRAINT `exams_to_classes_fk_examid_foreign` FOREIGN KEY(`fk_examId`) REFERENCES `Exams`(`id`);
ALTER TABLE
    `Exams_to_Classes` ADD CONSTRAINT `exams_to_classes_fk_classid_foreign` FOREIGN KEY(`fk_classId`) REFERENCES `Classes`(`id`);