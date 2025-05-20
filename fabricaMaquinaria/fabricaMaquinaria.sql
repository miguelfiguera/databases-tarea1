-- Optional: Drop and create the database for a fresh start from psql
-- \c postgres
DROP DATABASE IF EXISTS fabric_maquinary_db;
CREATE DATABASE fabric_maquinary_db;
\c fabric_maquinary_db

-- Drop tables in reverse order of creation to avoid FK errors
DROP TABLE IF EXISTS Department_Machinery CASCADE;
DROP TABLE IF EXISTS Salaries CASCADE;
DROP TABLE IF EXISTS Employees CASCADE;
DROP TABLE IF EXISTS Positions CASCADE;
DROP TABLE IF EXISTS Departments CASCADE;

-- 1. Departments (Information about the company's departments)
CREATE TABLE Departments (
    id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    location VARCHAR(100), -- e.g., "Building A, 3rd Floor"
    cost_center_code VARCHAR(50), -- Optional, for accounting
    creation_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Departments IS 'Stores information about the different departments in the company.';
COMMENT ON COLUMN Departments.department_name IS 'Unique name of the department.';

-- 2. Positions (Information about different job titles or roles)
CREATE TABLE Positions (
    id SERIAL PRIMARY KEY,
    position_title VARCHAR(100) UNIQUE NOT NULL,
    responsibilities_description TEXT,
    hierarchical_level INT, -- e.g., 1 (Operational), 2 (Supervisor), 3 (Manager), etc.
    minimum_salary DECIMAL(10, 2) CHECK (minimum_salary >= 0),
    maximum_salary DECIMAL(10, 2) CHECK (maximum_salary >= minimum_salary),
    creation_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE Positions IS 'Defines the different job titles or positions within the company.';
COMMENT ON COLUMN Positions.position_title IS 'Unique name of the job title or position.';

-- 3. Employees (Information about the company's employees)
CREATE TABLE Employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    national_id_number VARCHAR(20) UNIQUE NOT NULL, -- National ID or equivalent
    date_of_birth DATE,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O')), -- Male, Female, Other
    address TEXT,
    phone_number VARCHAR(20),
    corporate_email VARCHAR(100) UNIQUE,
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    department_id INT,
    position_id INT,
    supervisor_id INT, -- Self-reference for supervisory hierarchy
    employee_status VARCHAR(20) DEFAULT 'Active' CHECK (employee_status IN ('Active', 'Inactive', 'Suspended', 'Terminated')),
    creation_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_updated_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_department
        FOREIGN KEY(department_id)
        REFERENCES Departments(id)
        ON DELETE SET NULL, -- If the department is deleted, the employee's department is set to null
    CONSTRAINT fk_employee_position
        FOREIGN KEY(position_id)
        REFERENCES Positions(id)
        ON DELETE SET NULL, -- If the position is deleted, the employee's position is set to null
    CONSTRAINT fk_employee_supervisor
        FOREIGN KEY(supervisor_id)
        REFERENCES Employees(id) -- Supervisor is also an employee
        ON DELETE SET NULL -- If the supervisor is deleted, the employee's direct supervisor is set to null
);
COMMENT ON TABLE Employees IS 'Detailed information for each employee.';
COMMENT ON COLUMN Employees.supervisor_id IS 'ID of the employee who supervises this employee (hierarchy).';
CREATE INDEX idx_employees_department ON Employees(department_id);
CREATE INDEX idx_employees_position ON Employees(position_id);
CREATE INDEX idx_employees_email ON Employees(corporate_email);

-- 4. Salaries (Salary history for employees)
-- A separate table is created to maintain a history of salary changes.
CREATE TABLE Salaries (
    id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    salary_amount DECIMAL(12, 2) NOT NULL CHECK (salary_amount >= 0),
    effective_start_date DATE NOT NULL,
    effective_end_date DATE, -- NULL if it's the current salary
    currency_code CHAR(3) DEFAULT 'USD' NOT NULL, -- e.g., USD, EUR, MXN
    payment_frequency VARCHAR(50) DEFAULT 'Monthly' CHECK (payment_frequency IN ('Weekly', 'Bi-Weekly', 'Monthly', 'Annual')),
    notes TEXT,
    record_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_salary_employee
        FOREIGN KEY(employee_id)
        REFERENCES Employees(id)
        ON DELETE CASCADE, -- If the employee is deleted, their salary history is also deleted
    CONSTRAINT chk_salary_dates CHECK (effective_end_date IS NULL OR effective_end_date > effective_start_date)
);
COMMENT ON TABLE Salaries IS 'History of salaries assigned to employees.';
COMMENT ON COLUMN Salaries.effective_end_date IS 'Date until which this salary was valid (NULL if current).';
CREATE INDEX idx_salaries_employee ON Salaries(employee_id);
CREATE INDEX idx_salaries_start_date ON Salaries(effective_start_date);

-- 5. Department_Machinery (Inventory of machinery or important equipment per department)
CREATE TABLE Department_Machinery (
    id SERIAL PRIMARY KEY,
    machine_name VARCHAR(150) NOT NULL,
    inventory_code VARCHAR(50) UNIQUE, -- Unique inventory code for the machine
    department_id INT NOT NULL,
    usage_description TEXT,
    brand VARCHAR(100),
    model VARCHAR(100),
    serial_number VARCHAR(100) UNIQUE,
    acquisition_date DATE,
    acquisition_cost DECIMAL(15, 2),
    machine_status VARCHAR(50) DEFAULT 'Operational' CHECK (machine_status IN ('Operational', 'Under Maintenance', 'Damaged', 'Obsolete', 'Decommissioned')),
    last_maintenance_date DATE,
    notes TEXT,
    record_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_updated_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_machinery_department
        FOREIGN KEY(department_id)
        REFERENCES Departments(id)
        ON DELETE RESTRICT -- Cannot delete a department if it has associated machinery (machinery should be reassigned or decommissioned first)
);
COMMENT ON TABLE Department_Machinery IS 'Inventory of significant machinery or equipment assigned to each department.';
COMMENT ON COLUMN Department_Machinery.inventory_code IS 'Unique code to identify the machine in the inventory.';
CREATE INDEX idx_machinery_department ON Department_Machinery(department_id);
CREATE INDEX idx_machinery_inventory_code ON Department_Machinery(inventory_code);

