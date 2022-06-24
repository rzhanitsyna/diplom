CREATE DATABASE IF NOT EXISTS diplom;

USE diplom;

CREATE TABLE IF NOT EXISTS `diplom`.`UserType` (
    `TypeName` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`TypeName`)
);

CREATE TABLE IF NOT EXISTS `diplom`.`Position` (
    `PositionName` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`PositionName`)
);

CREATE TABLE IF NOT EXISTS `diplom`.`Status` (
    `StatusName` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`StatusName`)
);

CREATE TABLE IF NOT EXISTS `diplom`.`Reception` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `Diagnosis` VARCHAR(255) NOT NULL DEFAULT '-',
    `Medication` VARCHAR(255) NOT NULL DEFAULT '-',
    `Clarification` VARCHAR(255) NOT NULL DEFAULT '-',
    PRIMARY KEY (`ID`)
);

CREATE TABLE IF NOT EXISTS `diplom`.`User` (
    `Login` VARCHAR(45) NOT NULL,
    `Password` VARCHAR(45) NOT NULL,
    `Name` VARCHAR(45) NOT NULL,
    `Surname` VARCHAR(45) NOT NULL,
    `Patronymic` VARCHAR(45) NULL,
    `Phone` VARCHAR(20) NOT NULL,
    `Photo` VARCHAR(255) NULL,
    `UserType` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`Login`),
    FOREIGN KEY (`UserType`) REFERENCES `diplom`.`UserType` (`TypeName`) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `diplom`.`Employee` (
    `Login` VARCHAR(45) NOT NULL,
    `PositionName` VARCHAR(100) NOT NULL,
    FOREIGN KEY (`Login`) REFERENCES `diplom`.`User` (`Login`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`PositionName`) REFERENCES `diplom`.`Position` (`PositionName`) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `diplom`.`Patient` (
    `Login` VARCHAR(45) NOT NULL,
    `Address` VARCHAR(45) NOT NULL,
    `Passport` VARCHAR(45) NOT NULL,
    `MedicalPolicy` VARCHAR(45) NOT NULL,
    `BookId` INT NOT NULL,
    FOREIGN KEY (`Login`) REFERENCES `diplom`.`User` (`Login`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `diplom`.`Recording` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `DateTime` DATETIME NOT NULL,
    `EmployeeID` VARCHAR(45) NOT NULL,
    `PatientID` VARCHAR(45) NOT NULL,
    `ReceptionID` INT,
    `StatusID` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`EmployeeID`) REFERENCES `diplom`.`Employee` (`Login`) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`PatientID`) REFERENCES `diplom`.`Patient` (`Login`) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`ReceptionID`) REFERENCES `diplom`.`Reception` (`ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`StatusID`) REFERENCES `diplom`.`Status` (`StatusName`) ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO
    `diplom`.`UserType` (`TypeName`)
VALUES
    ("Сотрудник");

INSERT INTO
    `diplom`.`UserType` (`TypeName`)
VALUES
    ("Пациент");

INSERT INTO
    `diplom`.`Position` (`PositionName`)
VALUES
    ("Медсестра");

INSERT INTO
    `diplom`.`Position` (`PositionName`)
VALUES
    ("Терапевт");

INSERT INTO
    `diplom`.`Position` (`PositionName`)
VALUES
    ("Дерматолог");

INSERT INTO
    `diplom`.`Status` (`StatusName`)
VALUES
    ("Назначен");

INSERT INTO
    `diplom`.`Status` (`StatusName`)
VALUES
    ("Отменен");

INSERT INTO
    `diplom`.`Status` (`StatusName`)
VALUES
    ("Окончен");

INSERT INTO
    `diplom`.`User` (
        `Login`,
        `Password`,
        `Name`,
        `Surname`,
        `Patronymic`,
        `Phone`,
        `Photo`,
        `UserType`
    )
VALUES
    (
        "Super777@gmail.com",
        "qwerty",
        "Инга",
        "Попова",
        "Игоревна",
        "+79117777777",
        "1.png",
        "Сотрудник"
    );

INSERT INTO
    `diplom`.`Employee` (`Login`, `PositionName`)
VALUES
    ("Super777@gmail.com", "Медсестра");

SELECT
    DateTime,
    StatusID,
    patient.Name AS pName,
    patient.Surname AS pSurname,
    patient.Patronymic AS pPatronymic,
    employee.Name AS eName,
    employee.Surname AS eSurname,
    employee.Patronymic AS ePatronymic,
    moreemployee.PositionName
FROM
    recording
    JOIN user AS patient ON patient.Login = recording.PatientID
    JOIN user AS employee ON employee.Login = recording.EmployeeID
    JOIN employee as moreemployee ON moreemployee.Login = recording.EmployeeID
WHERE
    StatusID = ?
    AND patient.Login = ?
ORDER BY
    DateTime;

UPDATE
    recording
SET
    StatusID = "Отменен"
WHERE
    ID = 1056;

SELECT
    ID,
    DateTime,
    StatusID,
    patient.Name AS pName,
    patient.Surname AS pSurname,
    patient.Patronymic AS pPatronymic,
    employee.Name AS eName,
    employee.Surname AS eSurname,
    employee.Patronymic AS ePatronymic,
    moreemployee.PositionName
FROM
    recording
    JOIN user AS patient ON patient.Login = recording.PatientID
    JOIN user AS employee ON employee.Login = recording.EmployeeID
    JOIN employee as moreemployee ON moreemployee.Login = recording.EmployeeID
WHERE
    ID = 36
ORDER BY
    DateTime;

SELECT
    recording.ID,
    DateTime,
    StatusID,
    patient.Name AS pName,
    patient.Surname AS pSurname,
    patient.Patronymic AS pPatronymic,
    reception.ID as receptionID,
    reception.Diagnosis,
    reception.Medication,
    reception.Clarification
FROM
    recording
    INNER JOIN reception ON receptionID = recording.ReceptionID
    INNER JOIN user AS patient ON patient.Login = recording.PatientID
WHERE
    recording.ID = 37
ORDER BY
    DateTime;

SELECT
    recording.ID,
    DateTime,
    StatusID,
    reception.ID as receptionID,
    reception.Diagnosis,
    reception.Medication,
    reception.Clarification
FROM
    recording
WHERE
    recording.ID = 37
    right JOIN reception ON receptionID = recording.ReceptionID
ORDER BY
    DateTime;



SELECT
    rec.ID,
    rec.DateTime,
    rec.StatusID,
    reception.ID,
    reception.Diagnosis,
    reception.Medication,
    reception.Clarification
FROM
    (
        SELECT
            *
        FROM
            recording
        WHERE
            recording.ID = 37
    ) as rec
    JOIN reception ON rec.receptionID = reception.ID
ORDER BY
    DateTime;