-- Create Database
CREATE DATABASE TrainReservationDB;
USE TrainReservationDB;

-- Create Train Table
CREATE TABLE Train (
    TrainID INT PRIMARY KEY AUTO_INCREMENT,
    TrainName VARCHAR(100) NOT NULL,
    Source VARCHAR(50),
    Destination VARCHAR(50),
    DepartureTime TIME,
    ArrivalTime TIME,
    TotalSeats INT,
    AvailableSeats INT
);

-- Create Passenger Table
CREATE TABLE Passenger (
    PassengerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Age INT,
    Gender CHAR(1),
    ContactNumber VARCHAR(15)
);

-- Create Reservation Table
CREATE TABLE Reservation (
    ReservationID INT PRIMARY KEY AUTO_INCREMENT,
    PassengerID INT,
    TrainID INT,
    SeatNumber INT,
    BookingDate DATE,
    TravelDate DATE,
    Status ENUM('Booked', 'Cancelled'),
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID) ON DELETE CASCADE,
    FOREIGN KEY (TrainID) REFERENCES Train(TrainID) ON DELETE CASCADE
);

-- Create Payment Table
CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    ReservationID INT,
    Amount DECIMAL(10, 2),
    PaymentDate DATE,
    PaymentStatus ENUM('Paid', 'Pending', 'Failed'),
    FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID) ON DELETE CASCADE
);

-- Insert Sample Data into Train Table
INSERT INTO Train (TrainName, Source, Destination, DepartureTime, ArrivalTime, TotalSeats, AvailableSeats)
VALUES
('Express 101', 'Delhi', 'Mumbai', '09:00:00', '18:00:00', 200, 200),
('Superfast 202', 'Hyderabad', 'Bangalore', '11:00:00', '19:30:00', 150, 150),
('Rajdhani Express', 'Kolkata', 'Delhi', '14:00:00', '08:00:00', 300, 300);

-- Insert Sample Data into Passenger Table
INSERT INTO Passenger (FirstName, LastName, Age, Gender, ContactNumber)
VALUES
('Venkata', 'Kishor', 24, 'M', '9876543210'),
('Ravi', 'Teja', 30, 'M', '9123456789'),
('Ananya', 'Sharma', 28, 'F', '9988776655');

-- Insert Sample Data into Reservation Table
INSERT INTO Reservation (PassengerID, TrainID, SeatNumber, BookingDate, TravelDate, Status)
VALUES
(1, 1, 5, '2025-03-15', '2025-03-20', 'Booked'),
(2, 2, 10, '2025-03-14', '2025-03-22', 'Booked'),
(3, 3, 20, '2025-03-10', '2025-03-25', 'Cancelled');

-- Insert Sample Data into Payment Table
INSERT INTO Payment (ReservationID, Amount, PaymentDate, PaymentStatus)
VALUES
(1, 1500.00, '2025-03-15', 'Paid'),
(2, 1200.00, '2025-03-14', 'Paid'),
(3, 2000.00, '2025-03-10', 'Failed');

-- Stored Procedure to Book a Ticket
DELIMITER //
CREATE PROCEDURE BookTicket(
    IN p_PassengerID INT,
    IN p_TrainID INT,
    IN p_SeatNumber INT,
    IN p_BookingDate DATE,
    IN p_TravelDate DATE
)
BEGIN
    INSERT INTO Reservation (PassengerID, TrainID, SeatNumber, BookingDate, TravelDate, Status)
    VALUES (p_PassengerID, p_TrainID, p_SeatNumber, p_BookingDate, p_TravelDate, 'Booked');
    
    UPDATE Train
    SET AvailableSeats = AvailableSeats - 1
    WHERE TrainID = p_TrainID;
END //
DELIMITER ;

-- Trigger to Update Available Seats on Cancellation
DELIMITER //
CREATE TRIGGER AfterCancel
AFTER UPDATE ON Reservation
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Cancelled' THEN
        UPDATE Train
        SET AvailableSeats = AvailableSeats + 1
        WHERE TrainID = NEW.TrainID;
    END IF;
END;
//
DELIMITER ;
