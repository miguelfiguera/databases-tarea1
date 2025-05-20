DROP DATABASE IF EXISTS library_system;
CREATE DATABASE library_system;
\c library_system

-- Drop tables in reverse order of creation to avoid FK errors
DROP TABLE IF EXISTS Book_Categories CASCADE;
DROP TABLE IF EXISTS Aisle_Categories CASCADE;
DROP TABLE IF EXISTS Categories CASCADE;
DROP TABLE IF EXISTS Loans CASCADE;
DROP TABLE IF EXISTS Inventory CASCADE;
DROP TABLE IF EXISTS Library_Users CASCADE;
DROP TABLE IF EXISTS Books CASCADE;
DROP TABLE IF EXISTS Aisles CASCADE;

-- 1. Aisles (Information about physical aisles in the library)
CREATE TABLE Aisles (
    id SERIAL PRIMARY KEY,
    aisle_number VARCHAR(10) UNIQUE NOT NULL, -- e.g., "A1", "B2-North"
    number_of_shelves INT NOT NULL CHECK (number_of_shelves > 0),
    rows_per_shelf INT NOT NULL CHECK (rows_per_shelf > 0),
    location_description TEXT, -- e.g., "Fiction Section, 2nd Floor"
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Books (Information about each book)
CREATE TABLE Books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    publication_year INT CHECK (publication_year > 0 AND publication_year <= EXTRACT(YEAR FROM CURRENT_DATE) + 1), -- Allow for books published next year
    isbn VARCHAR(20) UNIQUE, -- International Standard Book Number, can be NULL if not applicable
    call_number VARCHAR(50) UNIQUE NOT NULL, -- Library's unique identifier for locating the book
    publisher VARCHAR(150),
    edition VARCHAR(50),
    language VARCHAR(50),
    number_of_pages INT CHECK (number_of_pages > 0),
    summary TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_books_title ON Books(title);
CREATE INDEX idx_books_author ON Books(author);
CREATE INDEX idx_books_call_number ON Books(call_number);

-- 3. Library_Users (Information about library members)
CREATE TABLE Library_Users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    address TEXT,
    membership_id VARCHAR(50) UNIQUE NOT NULL,
    join_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Suspended', 'Inactive')),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_library_users_email ON Library_Users(email);
CREATE INDEX idx_library_users_membership_id ON Library_Users(membership_id);

-- 4. Inventory (Tracks individual copies of books and their location)
CREATE TABLE Inventory (
    id SERIAL PRIMARY KEY, -- Unique ID for each physical copy
    book_id INT NOT NULL,
    aisle_id INT, -- Where the book is generally located
    shelf_number INT,
    row_number INT,
    copy_number INT DEFAULT 1, -- If multiple copies of the same book edition
    acquisition_date DATE,
    condition VARCHAR(50) DEFAULT 'Good' CHECK (condition IN ('New', 'Good', 'Fair', 'Poor', 'Damaged', 'Lost')),
    status VARCHAR(20) DEFAULT 'Available' CHECK (status IN ('Available', 'On Loan', 'Reserved', 'In Repair', 'Lost')),
    notes TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_book
        FOREIGN KEY(book_id)
        REFERENCES Books(id)
        ON DELETE CASCADE, -- If the book record is deleted, its inventory copies are also deleted
    CONSTRAINT fk_inventory_aisle
        FOREIGN KEY(aisle_id)
        REFERENCES Aisles(id)
        ON DELETE SET NULL -- If an aisle is deleted, the book's location can be set to unknown
);
CREATE INDEX idx_inventory_book_id ON Inventory(book_id);
CREATE INDEX idx_inventory_aisle_id ON Inventory(aisle_id);
CREATE INDEX idx_inventory_status ON Inventory(status);

-- 5. Loans (Tracks books borrowed by users)
CREATE TABLE Loans (
    id SERIAL PRIMARY KEY,
    inventory_id INT NOT NULL UNIQUE, -- Each specific copy can only be loaned once at a time
    user_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    return_date DATE, -- NULL if not yet returned
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Returned', 'Overdue', 'Lost')),
    fine_amount DECIMAL(8, 2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_loan_inventory
        FOREIGN KEY(inventory_id)
        REFERENCES Inventory(id)
        ON DELETE RESTRICT, -- Cannot delete an inventory item if it's part of an active loan
    CONSTRAINT fk_loan_user
        FOREIGN KEY(user_id)
        REFERENCES Library_Users(id)
        ON DELETE RESTRICT, -- Cannot delete a user if they have active loans
    CONSTRAINT chk_loan_dates CHECK (due_date >= loan_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= loan_date)
);
CREATE INDEX idx_loans_inventory_id ON Loans(inventory_id);
CREATE INDEX idx_loans_user_id ON Loans(user_id);
CREATE INDEX idx_loans_due_date ON Loans(due_date);
CREATE INDEX idx_loans_status ON Loans(status);

-- 6. Categories (General categories for books and/or aisles)
CREATE TABLE Categories (
    id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Book_Categories (Join table for many-to-many relationship between Books and Categories)
CREATE TABLE Book_Categories (
    book_id INT NOT NULL,
    category_id INT NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id, category_id), -- Composite primary key
    CONSTRAINT fk_book_category_book
        FOREIGN KEY(book_id)
        REFERENCES Books(id)
        ON DELETE CASCADE, -- If a book is deleted, its category associations are also deleted
    CONSTRAINT fk_book_category_category
        FOREIGN KEY(category_id)
        REFERENCES Categories(id)
        ON DELETE CASCADE -- If a category is deleted, its book associations are also deleted
);

-- 8. Aisle_Categories (Join table for many-to-many relationship between Aisles and Categories)
CREATE TABLE Aisle_Categories (
    aisle_id INT NOT NULL,
    category_id INT NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (aisle_id, category_id), -- Composite primary key
    CONSTRAINT fk_aisle_category_aisle
        FOREIGN KEY(aisle_id)
        REFERENCES Aisles(id)
        ON DELETE CASCADE, -- If an aisle is deleted, its category associations are also deleted
    CONSTRAINT fk_aisle_category_category
        FOREIGN KEY(category_id)
        REFERENCES Categories(id)
        ON DELETE CASCADE -- If a category is deleted, its aisle associations are also deleted
);