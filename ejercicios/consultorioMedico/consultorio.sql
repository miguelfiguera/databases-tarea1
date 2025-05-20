CREATE DATABASE consultorio_medico;

\c consultorio_medico

-- Drop tables in reverse order of creation to avoid FK errors
DROP TABLE IF EXISTS Invoices CASCADE;
DROP TABLE IF EXISTS Office_Assignments CASCADE; -- Renamed from "Consultorios_Ocupacion"
DROP TABLE IF EXISTS Appointments CASCADE;
DROP TABLE IF EXISTS Applied_Treatments CASCADE;
DROP TABLE IF EXISTS Medical_Records CASCADE;
DROP TABLE IF EXISTS Patients CASCADE;
DROP TABLE IF EXISTS Doctors CASCADE;
DROP TABLE IF EXISTS Specialties CASCADE;
DROP TABLE IF EXISTS Treatments CASCADE;


-- NEW AND MODIFIED TABLES

-- 1. Specialties
CREATE TABLE Specialties (
    id SERIAL PRIMARY KEY,
    specialty_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

-- 2. Doctors
CREATE TABLE Doctors (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    specialty_id INT, -- Foreign key to Specialties
    phone_number VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    professional_license_number VARCHAR(50) UNIQUE,
    CONSTRAINT fk_doctor_specialty
        FOREIGN KEY(specialty_id)
        REFERENCES Specialties(id)
        ON DELETE SET NULL -- If a specialty is deleted, the doctor's specialty is set to null
);

-- 3. Patients
CREATE TABLE Patients (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O')), -- Male, Female, Other
    address TEXT,
    phone_number VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    social_security_number VARCHAR(50) UNIQUE -- Or national_id_number depending on context
);

-- 4. Medical_Records
CREATE TABLE Medical_Records (
    id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL UNIQUE, -- One record per patient
    creation_date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    personal_history TEXT,
    family_history TEXT,
    allergies TEXT,
    general_notes TEXT,
    CONSTRAINT fk_medical_record_patient
        FOREIGN KEY(patient_id)
        REFERENCES Patients(id)
        ON DELETE CASCADE -- If a patient is deleted, their medical record is also deleted
);

-- 5. Appointments
CREATE TABLE Appointments (
    id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_datetime TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    reason_for_visit TEXT,
    appointment_status VARCHAR(20) DEFAULT 'Scheduled' CHECK (appointment_status IN ('Scheduled', 'Confirmed', 'Cancelled', 'Completed', 'No Show')),
    appointment_notes TEXT, -- Specific notes for this appointment
    CONSTRAINT fk_appointment_patient
        FOREIGN KEY(patient_id)
        REFERENCES Patients(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_appointment_doctor
        FOREIGN KEY(doctor_id)
        REFERENCES Doctors(id)
        ON DELETE RESTRICT -- Cannot delete a doctor if they have scheduled appointments
);
CREATE INDEX idx_appointments_datetime ON Appointments(appointment_datetime);
CREATE INDEX idx_appointments_doctor_datetime ON Appointments(doctor_id, appointment_datetime);
CREATE INDEX idx_appointments_patient_datetime ON Appointments(patient_id, appointment_datetime);


-- 6. Office_Assignments (Refined concept of "Consultorios" / "Rooms")
-- This table can record which doctor uses which office/room and when.
-- You could have a separate "Offices_Catalog" table if you have several physical rooms with distinct features.
CREATE TABLE Office_Assignments (
    id SERIAL PRIMARY KEY,
    doctor_id INT NOT NULL,
    office_identifier VARCHAR(20) NOT NULL, -- E.g., "Room 1", "Office A", "Consulting Room 3"
    start_datetime TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    end_datetime TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    patients_seen_in_session INT DEFAULT 0,
    session_notes TEXT,
    CONSTRAINT fk_assignment_doctor
        FOREIGN KEY(doctor_id)
        REFERENCES Doctors(id)
        ON DELETE CASCADE, -- If the doctor is deleted, their assignment records are deleted
    CONSTRAINT chk_assignment_datetimes CHECK (end_datetime > start_datetime)
);
CREATE INDEX idx_assignment_doctor_datetime ON Office_Assignments(doctor_id, start_datetime);

-- 7. Treatments (Catalog of available treatments)
CREATE TABLE Treatments (
    id SERIAL PRIMARY KEY,
    treatment_name VARCHAR(255) UNIQUE NOT NULL,
    treatment_description TEXT,
    estimated_cost DECIMAL(10, 2) -- Optional, if you want to register base costs
);

-- 8. Applied_Treatments (Join table between Medical_Records/Appointments and Treatments)
-- A patient can have multiple treatments, and a treatment can be applied to multiple patients.
-- Can be linked to the general medical record or a specific appointment.
CREATE TABLE Applied_Treatments (
    id SERIAL PRIMARY KEY,
    medical_record_id INT, -- Can be associated with the general medical record
    appointment_id INT,    -- Or a specific appointment
    treatment_id INT NOT NULL,
    treatment_start_date DATE NOT NULL,
    treatment_end_date DATE,
    treatment_status VARCHAR(50) DEFAULT 'Prescribed' CHECK (treatment_status IN ('Prescribed', 'In Progress', 'Completed', 'Suspended', 'Cancelled')),
    treatment_notes TEXT,
    prescribing_doctor_id INT, -- Doctor who prescribed/supervises the treatment
    CONSTRAINT fk_applied_treatment_medical_record
        FOREIGN KEY(medical_record_id)
        REFERENCES Medical_Records(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_applied_treatment_appointment
        FOREIGN KEY(appointment_id)
        REFERENCES Appointments(id)
        ON DELETE SET NULL, -- If the appointment is deleted, the applied treatment might remain (unlinked)
    CONSTRAINT fk_applied_treatment_catalog
        FOREIGN KEY(treatment_id)
        REFERENCES Treatments(id)
        ON DELETE RESTRICT, -- Cannot delete a treatment from the catalog if it's in use
    CONSTRAINT fk_applied_treatment_prescribing_doctor
        FOREIGN KEY(prescribing_doctor_id)
        REFERENCES Doctors(id)
        ON DELETE SET NULL,
    CONSTRAINT chk_record_or_appointment CHECK ( (medical_record_id IS NOT NULL AND appointment_id IS NULL) OR (medical_record_id IS NULL AND appointment_id IS NOT NULL) OR (medical_record_id IS NOT NULL AND appointment_id IS NOT NULL) )
    -- Ensures the treatment is associated with at least a medical record or an appointment, or both.
    -- You could simplify this if the business rule is stricter (e.g., "a treatment is always associated with one or the other").
);

-- 9. Invoices
CREATE TABLE Invoices (
    id SERIAL PRIMARY KEY,
    appointment_id INT, -- The invoice can be associated with an appointment
    patient_id INT NOT NULL,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'Pending' CHECK (payment_status IN ('Pending', 'Paid', 'Partially Paid', 'Cancelled', 'Refunded')),
    payment_method VARCHAR(50),
    payment_date DATE,
    payment_reference VARCHAR(100),
    invoice_notes TEXT,
    CONSTRAINT fk_invoice_appointment
        FOREIGN KEY(appointment_id)
        REFERENCES Appointments(id)
        ON DELETE SET NULL, -- If the appointment is deleted, the invoice may remain
    CONSTRAINT fk_invoice_patient
        FOREIGN KEY(patient_id)
        REFERENCES Patients(id)
        ON DELETE RESTRICT -- Cannot delete a patient with pending/existing invoices
);
CREATE INDEX idx_invoice_patient ON Invoices(patient_id);
CREATE INDEX idx_invoice_payment_status ON Invoices(payment_status);
