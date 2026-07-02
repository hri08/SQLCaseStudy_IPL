CREATE TABLE PatientVisits (
	VisitID varchar(20),
	PatientID varchar(20),
	DoctorID varchar(20),
	DepartmentID varchar(20),
	DiagnosisID varchar(20),
	TreatmentID varchar(20),
	PaymentMethodID varchar(20),
	VisitDate date,
	VisitTime time,
	DischargeDate date,
	BillAmount decimal(18,2),
	InsuranceAmount decimal(18,2),
	SatisfactionScore INT,
	WaitTimeMinutes INT

	-- Optional to add Foriegn Keys i.e. Tables created
	FOREIGN KEY (PatientID)         REFERENCES Dim_Patient_Clean,
	FOREIGN KEY (DoctorID)          REFERENCES Dim_Doctor,
	FOREIGN KEY (DepartmentID)      REFERENCES DIM_Department_Clean,
	FOREIGN KEY (DiagnosisID)       REFERENCES Dim_Diagnosis,
	FOREIGN KEY (TreatmentID)       REFERENCES Dim_Treatment,
	FOREIGN KEY (PaymentMethodID)   REFERENCES Dim_PaymentMethod
);



INSERT INTO PatientVisits(
	  VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID, PaymentMethodID,
	 VisitDate, VisitTime, DischargeDate,BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes 
)
SELECT 
      VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID, PaymentMethodID, 
	  VisitDate, VisitTime, DischargeDate,BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes 

FROM PatientVisits_2020_2021

UNION ALL

SELECT 
      VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID, PaymentMethodID,
	  VisitDate, VisitTime, DischargeDate,BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes 

FROM PatientVisits_2022_2023

UNION ALL

SELECT 
      VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID, PaymentMethodID,
	 VisitDate, VisitTime, DischargeDate,BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes 

FROM PatientVisits_2024

UNION ALL

SELECT 
      VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID, PaymentMethodID,
	 VisitDate, VisitTime, DischargeDate,BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes 

FROM PatientVisits_2025



CREATE TABLE DIM_Department_Clean (
	DepartmentID varchar (20) PRIMARY KEY,
	DepartmentName varchar (100),
	DepartmentCategory varchar(100)
)

INSERT INTO DIM_Department_Clean (
DepartmentID, DepartmentName, DepartmentCategory
)

SELECT d.DepartmentID, d.Specialization AS DepartmentName, d.DepartmentCategory
FROM DIM_Department d
WHERE d.DepartmentCategory IS NOT NULL

-- 1. For each doctor, count how many distinct patients thay have treated.

SELECT doc.DoctorID, doc.FirstName + ' ' + doc.LastName, COUNT(DISTINCT v.PatientID) AS DistinctPatients
FROM PatientVisits v
JOIN Dim_Doctor doc
ON v.DoctorID = doc.DoctorID
GROUP BY doc.DoctorID, doc.FirstName, doc.LastName
ORDER BY DistinctPatients DESC

-- 2. Show the revenue split by each payment method, along with the total visits.
SELECT pm.PaymentMethod,
	   COUNT(v.VisitID) AS TotalVisits,
	   SUM(v.BillAmount) AS TotalRevenue
FROM PatientVisits v
JOIN Dim_PaymentMethod pm
ON v.PaymentMethodID = pm.PaymentMethodID
GROUP BY pm.PaymentMethod




-- 3 Categorize patients into age groups and calculate the average bill amount for each age band.(Assume the age at the time of the treatment)

WITH cte_PatientAge AS (
SELECT v.VisitID, v.BillAmount,
	CASE
		WHEN DATEDIFF(YEAR, p.DOB, v.VisitDate) < 18 THEN '0-17'
		WHEN DATEDIFF(YEAR, p.DOB, v.VisitDate) BETWEEN 18 AND 35 THEN '18-35'
		WHEN DATEDIFF(YEAR, p.DOB, v.VisitDate) BETWEEN 36 AND 55 THEN '36-55'
		ELSE '56+'
	END AS AgeGroup
FROM DIM_Patient_Clean p
JOIN PatientVisits v
ON v.PatientID = p.PatientID
)
SELECT AgeGroup,
	COUNT(*) AS TotalVisits,
	CAST(AVG(BillAmount) AS DECIMAL (18,2)) AvgBillAmount
FROM cte_PatientAge
GROUP BY AgeGroup
ORDER BY
	CASE AgeGroup
		WHEN '0-17' THEN 1
		WHEN '18-35' THEN 2
		WHEN '36-55' THEN 3
		WHEN '56+' THEN 4
	END; 

	-- 4. Find the total revenue and the number of visits for each department.

	SELECT d.DepartmentName,
		   COUNT(v.VisitID) AS TotalVisits,
		   SUM(v.BillAmount) AS TotalRevenue
	FROM PatientVisits v
	JOIN DIM_Department_Clean d
	ON v.DepartmentID = d.DepartmentID
	GROUP BY d.DepartmentName
	ORDER BY TotalRevenue DESC

	-- 5. Rank departments based on their total revenue within each department category.

	SELECT 	DepartmentCategory, DepartmentName, TotalRevenue,
	        RANK() OVER (PARTITION BY departmentCategory ORDER BY TotalRevenue DESC) AS RevenueRank
		
FROM(		
		SELECT d.departmentCategory, d.DepartmentName,
			   SUM(v.BillAmount) AS TotalRevenue
		FROM PatientVisits v
		Join DIM_Department_Clean d
		ON v.DepartmentID = d.DepartmentID
		GROUP BY d.DepartmentCategory, d.DepartmentName
) t


-- 6. For each department, find the average satisfaction score and the average wait time.
SELECT d.DepartmentName,
	   AVG(v.SatisfactionScore) AS AvgSatisfactionScore,
	   AVG(v.WaitTimeMinutes) AS AvgWaitTimeMinutes
FROM PatientVisits v
JOIN DIM_Department_Clean d
ON v.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName
ORDER BY AvgSatisfactionScore DESC

SELECT *
FROM PatientVisits


-- 7. Compare the total number of hospital visits on weekdays vs weekend.

SELECT DayType, COUNT(*) AS TotalVisits
FROM
(
	SELECT
		CASE
			WHEN DATENAME(Weekday, VisitDate) IN ('Saturday','Sunday')
			THEN 'Weekend'
			ELSE 'Weekday'
		END AS DayType
	FROM PatientVisits
)t
GROUP BY DayType


-- 8. For each month, calculate the total visits and a running cumulative total of visits.
WITH cte_monthlyVisits AS (
	SELECT 
		DATEFROMPARTS(YEAR(VisitDate), MONTH(VisitDate), 1) AS MonthStart,
		COUNT(*) AS TotalVisits
	FROM PatientVisits
	GROUP BY YEAR(VisitDate), MONTH(VisitDate)

)
SELECT  MonthStart, TotalVisits,
	    SUM(TotalVisits) OVER (ORDER BY MonthStart
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeVisits
FROM cte_monthlyVisits
ORDER BY MonthStart


--9. Find the doctors with the highest average satisfaction score (minimum 100 visits).

SELECT d.DoctorID, d.FirstName + '' + d.LastName AS DoctorName,
	   COUNT(v.VisitID) AS TotalVisits,
	   CAST(AVG(v.SatisfactionScore) AS DECIMAL(10,2)) AS AvgSatisfactionScore
FROM DIM_Doctor d
JOIN PatientVisits v
ON d.DoctorID = v.DoctorID
GROUP BY d.DoctorID, d.FirstName, d.LastName
HAVING COUNT(v.VisitID) > 100

-- 10. Identify the most commonly prescribed treatment for each diagnosis.


WITH CTE_Treatment AS(
	SELECT d.DiagnosisName, t.TreatmentName, COUNT(*) AS TreatmentCount,
		   RANK() OVER(PARTITION BY d.DiagnosisName ORDER BY COUNT(*) DESC) AS rn
	FROM PatientVisits v
	JOIN Dim_Diagnosis d
	ON v.DiagnosisID = d.DiagnosisID
	JOIN Dim_Treatment t
	ON t.TreatmentID = v.TreatmentID
	GROUP BY  d.DiagnosisName, t.TreatmentName
)
SELECT DiagnosisName, TreatmentName, TreatmentCount
FROM CTE_Treatment
WHERE rn = 1







