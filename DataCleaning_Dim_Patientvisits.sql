-- Data Cleaning (Patient Visits Table)
--- Merge all yearly visit tables (2020-2025) into one consolidated Patient Visits Table

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
























































