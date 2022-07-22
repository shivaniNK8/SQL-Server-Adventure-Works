
USE db;
--Part A

CREATE TABLE dbo.Student(
	StudentID int IDENTITY NOT NULL PRIMARY KEY,
	LastName varchar(40) NOT NULL,
	FirstName varchar(40) NOT NULL,
	DateOfBirth date NOT NULL
);

CREATE TABLE dbo.Term(
	TermID int IDENTITY NOT NULL PRIMARY KEY,
	Year date NOT NULL,
	Term varchar(10) NOT NULL
);

CREATE TABLE dbo.Course(
	CourseID int IDENTITY NOT NULL PRIMARY KEY,
	Name varchar(40) NOT NULL,
	Description varchar(200) NOT NULL
);

CREATE TABLE dbo.Enrollment(
	StudentID int NOT NULL
		REFERENCES Student(StudentID),
	CourseID int NOT NULL
		REFERENCES Course(CourseID),
	TermID int NOT NULL
		REFERENCES Term(TermID),
		CONSTRAINT PKEnrollment PRIMARY KEY CLUSTERED
			(StudentID, CourseID, TermID) 
);

