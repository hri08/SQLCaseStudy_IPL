--Data Cleaning(Department Table)
--- Remove departments where Department Category is missing
--- Drop HOD and Department Columns
--- Use Specialization as Department Name Column


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


















































































































