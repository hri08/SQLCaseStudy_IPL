-- Data Cleaning (Patient Table)
--- Remove the patient rows with missing values
--- Standardize First and Last names to proper cases and create the Fullname column
--- Gender values should either be male or female
--- Split CityStateCountry inro its separate individual columns

CREATE TABLE Dim_Patient_Clean (
	PatientID varchar(20) PRIMARY KEY,
	FullName varchar(120),
	Gender varchar(10),
	DOB date,
	City varchar(50),
	State varchar(50),
	Country varchar(50)
)

INSERT INTO Dim_Patient_Clean (
		PatientID, FullName, Gender, DOB, City, State, Country
)
SELECT
	p.PatientID,
	UPPER(LEFT(LTRIM(RTRIM(p.FirstName)),1)) + SUBSTRING(LOWER(LTRIM(RTRIM(p.FirstName))), 2, LEN(LTRIM(RTRIM(p.FirstName))))  + ' ' +
	UPPER(LEFT(LTRIM(RTRIM(p.LastName)),1)) + SUBSTRING(LOWER(LTRIM(RTRIM(p.LastName))), 2, LEN(LTRIM(RTRIM(p.LastName)))) AS FullName,
	CASE	
		WHEN p.Gender = 'M' THEN 'Male'
		WHEN p.Gender = 'F' THEN 'Female'
		ELSE p.Gender
	END AS Gender,
	p.DOB,
	PARSENAME(REPLACE(p.CityStateCountry, ',' , '.'), 3) AS City,
	PARSENAME(REPLACE(p.CityStateCountry, ',' , '.'), 2) AS State,
	PARSENAME(REPLACE(p.CityStateCountry, ',' , '.'), 1) AS Country
	FROM Dim_Patient p
	WHERE p.FirstName IS NOT NULL

	SELECT *
	FROM Dim_Patient_Clean






















































































