create database employee;
use employee;

CREATE TABLE emp (
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	FIRST_NAME CHAR(25),
	LAST_NAME CHAR(25),
	SALARY INT(15),
	JOINING_DATE DATETIME,
	DEPARTMENT CHAR(25), 
    MANAGER_ID INT
);

INSERT INTO emp
	(id, FIRST_NAME, LAST_NAME, SALARY, JOINING_DATE, DEPARTMENT,MANAGER_ID) VALUES
		(001, 'James', 'Smith', 100000, '17-02-20 09.00.00', 'HR', 002),
		(002, 'Jessica', 'Kohl', 80000, '17-06-11 09.00.00', 'Admin', 005),
		(003, 'Alex', 'Garner', 300000, '17-02-20 09.00.00', 'HR', 011),
		(004, 'Pratik', 'Pandey', 500000, '17-02-20 09.00.00', 'Admin', 020),
		(005, 'Christine', 'Robinson', 500000, '17-06-11 09.00.00', 'Admin', 007),
		(006, 'Deepak', 'Gupta', 200000, '17-06-11 09.00.00', 'Account', 015),
		(007, 'Jennifer', 'Paul', 75000, '17-01-20 09.00.00', 'Account', 012),
		(008, 'Deepika', 'Sharma', 90000, '17-04-11 09.00.00', 'Admin', 017);

CREATE TABLE Bonus (
	empId INT,
	BONUS_AMOUNT INT(10),
	BONUS_DATE DATETIME,
	FOREIGN KEY (empId)
		REFERENCES emp(id)
        ON DELETE CASCADE
);

INSERT INTO Bonus 
	(empId, BONUS_AMOUNT, BONUS_DATE) VALUES
		(001, 5000, '18-02-20'),
		(002, 3000, '18-06-11'),
		(003, 4000, '18-02-20'),
		(001, 4500, '18-02-20'),
		(002, 3500, '18-06-11');


CREATE TABLE user_name (
full_names CHAR(30)
);

INSERT INTO user_name
(full_names) VALUES
('Jessica Taylor'),
('Erin Russell'),
('Amanda Smith'),
('Sam Brown'),
('Robert Kehrer');