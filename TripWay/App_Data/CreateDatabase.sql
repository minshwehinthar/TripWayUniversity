/* ============================================================
   TripWayDB — Hpa-An On-Demand Travel Platform
   Created by: TripWay setup
   Run against Docker SQL Server (sa / Asdffdsa1):
     docker compose up -d   (auto-runs this file on first start)
   or manually:
     /opt/mssql-tools18/bin/sqlcmd -S localhost,1433 -U sa -P Asdffdsa1 -C -i CreateDatabase.sql
   ============================================================ */

CREATE DATABASE TripWayDB;
GO

USE TripWayDB;
GO

/* ---------------- reference data ---------------- */

CREATE TABLE VehicleTypes (
    VehicleTypeID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    MinSeatCapacity INT NOT NULL,
    MaxSeatCapacity INT NOT NULL
);

CREATE TABLE ServiceTypes (
    ServiceTypeID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

/* ---------------- accounts ---------------- */

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    PhoneNumber NVARCHAR(20) NOT NULL,
    ProfilePhotoUrl NVARCHAR(300) NULL,
    Gender NVARCHAR(10) NULL,
    DefaultAddress NVARCHAR(300) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE Drivers (
    DriverID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    PhoneNumber NVARCHAR(20) NOT NULL,
    NRCNumber NVARCHAR(50) NOT NULL,
    NRCPhotoUrl NVARCHAR(300) NOT NULL,
    LicenseNumber NVARCHAR(50) NOT NULL,
    LicensePhotoUrl NVARCHAR(300) NOT NULL,
    VehicleTypeID INT NOT NULL FOREIGN KEY REFERENCES VehicleTypes(VehicleTypeID),
    VehiclePlateNumber NVARCHAR(30) NOT NULL,
    VehiclePhotoUrl NVARCHAR(300) NOT NULL,
    VehicleRegDocUrl NVARCHAR(300) NOT NULL,
    SeatCapacity INT NOT NULL,
    ProfilePhotoUrl NVARCHAR(300) NULL,
    PaymentAccount NVARCHAR(150) NULL,
    KYCStatus NVARCHAR(20) NOT NULL DEFAULT 'Pending',
    IsOnline BIT NOT NULL DEFAULT 0,
    CurrentLat DECIMAL(9,6) NULL,
    CurrentLng DECIMAL(9,6) NULL,
    AverageRating DECIMAL(3,2) NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE Admins (
    AdminID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    Role NVARCHAR(30) NOT NULL DEFAULT 'Admin',
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    ProfilePhotoUrl NVARCHAR(300) NULL
);

/* ---------------- packages / fares ---------------- */

CREATE TABLE Packages (
    PackageID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    DurationDays INT NOT NULL,
    FixedPrice DECIMAL(12,2) NOT NULL,
    CoverPhotoUrl NVARCHAR(300) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedByDriverID INT NULL FOREIGN KEY REFERENCES Drivers(DriverID),
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_Packages_Active ON Packages(IsActive, PackageID);

CREATE TABLE PackagePlaces (
    PackagePlaceID INT IDENTITY(1,1) PRIMARY KEY,
    PackageID INT NOT NULL FOREIGN KEY REFERENCES Packages(PackageID),
    PlaceName NVARCHAR(150) NOT NULL,
    Lat DECIMAL(9,6) NOT NULL,
    Lng DECIMAL(9,6) NOT NULL,
    OrderIndex INT NOT NULL
);

CREATE INDEX IX_PackagePlaces_Package ON PackagePlaces(PackageID, OrderIndex);

CREATE TABLE PackagePhotos (
    PackagePhotoID INT IDENTITY(1,1) PRIMARY KEY,
    PackageID INT NOT NULL FOREIGN KEY REFERENCES Packages(PackageID),
    PhotoUrl NVARCHAR(300) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_PackagePhotos_Package ON PackagePhotos(PackageID, SortOrder);

CREATE TABLE Hotels (
    HotelID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    Address NVARCHAR(300) NULL,
    Phone NVARCHAR(40) NULL,
    Email NVARCHAR(150) NULL,
    LogoPhotoUrl NVARCHAR(300) NULL,
    Lat DECIMAL(9,6) NOT NULL,
    Lng DECIMAL(9,6) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_Hotels_Active ON Hotels(IsActive, Name);

CREATE TABLE FareRates (
    FareRateID INT IDENTITY(1,1) PRIMARY KEY,
    VehicleTypeID INT NOT NULL FOREIGN KEY REFERENCES VehicleTypes(VehicleTypeID),
    ServiceTypeID INT NOT NULL FOREIGN KEY REFERENCES ServiceTypes(ServiceTypeID),
    -- BaseFare is retained for compatibility only; it is not read by any calculation.
    BaseFare DECIMAL(12,2) NOT NULL,
    PerKmRate DECIMAL(12,2) NULL,
    HourlyRate DECIMAL(12,2) NULL,
    UpdatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

/* ---------------- trips ---------------- */

CREATE TABLE Trips (
    TripID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    DriverID INT NULL FOREIGN KEY REFERENCES Drivers(DriverID),
    VehicleTypeID INT NOT NULL FOREIGN KEY REFERENCES VehicleTypes(VehicleTypeID),
    ServiceTypeID INT NOT NULL FOREIGN KEY REFERENCES ServiceTypes(ServiceTypeID),
    PackageID INT NULL FOREIGN KEY REFERENCES Packages(PackageID),
    HotelID INT NULL FOREIGN KEY REFERENCES Hotels(HotelID),
    PickupLat DECIMAL(9,6) NOT NULL,
    PickupLng DECIMAL(9,6) NOT NULL,
    PickupAddress NVARCHAR(300) NULL,
    DropoffLat DECIMAL(9,6) NULL,
    DropoffLng DECIMAL(9,6) NULL,
    DropoffAddress NVARCHAR(300) NULL,
    EstimatedKm DECIMAL(8,2) NULL,
    Hours INT NULL,
    Fare DECIMAL(12,2) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Requested',
    RequestedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    AcceptedAt DATETIME2 NULL,
    ArrivedAt DATETIME2 NULL,
    StartedAt DATETIME2 NULL,
    CompletedAt DATETIME2 NULL,
    PaymentMethod NVARCHAR(20) NULL,
    PaymentStatus NVARCHAR(20) NOT NULL DEFAULT 'Unpaid',
    EtaMinutes INT NULL,
    EtaSetAt DATETIME2 NULL
);

CREATE INDEX IX_Trips_Customer ON Trips(CustomerID);
CREATE INDEX IX_Trips_Driver ON Trips(DriverID);
CREATE INDEX IX_Trips_Status ON Trips(Status, VehicleTypeID);
CREATE INDEX IX_Trips_Hotel ON Trips(HotelID);

CREATE TABLE TripGPSLogs (
    LogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TripID INT NOT NULL FOREIGN KEY REFERENCES Trips(TripID),
    Lat DECIMAL(9,6) NOT NULL,
    Lng DECIMAL(9,6) NOT NULL,
    RecordedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_TripGPSLogs_Trip ON TripGPSLogs(TripID);

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    TripID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Trips(TripID),
    Amount DECIMAL(12,2) NOT NULL,
    Method NVARCHAR(20) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
    PaidAt DATETIME2 NULL
);

CREATE TABLE ChatMessages (
    MessageID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TripID INT NOT NULL FOREIGN KEY REFERENCES Trips(TripID),
    SenderType NVARCHAR(10) NOT NULL,
    SenderID INT NOT NULL,
    MessageText NVARCHAR(1000) NULL,
    PhotoUrl NVARCHAR(300) NULL,
    SentAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX IX_ChatMessages_Trip ON ChatMessages(TripID);

CREATE TABLE Ratings (
    RatingID INT IDENTITY(1,1) PRIMARY KEY,
    TripID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Trips(TripID),
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    DriverID INT NOT NULL FOREIGN KEY REFERENCES Drivers(DriverID),
    Score INT NOT NULL CHECK (Score BETWEEN 1 AND 5),
    Comment NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE ActivityLogs (
    LogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TripID INT NULL FOREIGN KEY REFERENCES Trips(TripID),
    EventType NVARCHAR(50) NOT NULL,
    Details NVARCHAR(500) NULL,
    RecordedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    /* Who caused the entry. The role is stored beside the id because Admins, Customers and
       Drivers each number their people from 1, so the id alone cannot say which table it means.
       Both are NULL for background work, which the logs page shows as "System". */
    CreatedByAccountId INT NULL,
    CreatedByRole NVARCHAR(20) NULL
);

CREATE INDEX IX_ActivityLogs_Trip ON ActivityLogs(TripID);
CREATE INDEX IX_ActivityLogs_Actor ON ActivityLogs(CreatedByRole, CreatedByAccountId);

/* ---------------- seed data ---------------- */

SET IDENTITY_INSERT VehicleTypes ON;
INSERT INTO VehicleTypes (VehicleTypeID, Name, MinSeatCapacity, MaxSeatCapacity) VALUES
    (1, N'Motorbike', 1, 1),
    (2, N'Tuk-Tuk', 1, 4),
    (3, N'Saloon', 1, 4),
    (4, N'VIP Van', 1, 10);
SET IDENTITY_INSERT VehicleTypes OFF;

SET IDENTITY_INSERT ServiceTypes ON;
INSERT INTO ServiceTypes (ServiceTypeID, Name) VALUES
    (1, N'Point-to-Point'),
    (2, N'Hourly'),
    (3, N'Package');
SET IDENTITY_INSERT ServiceTypes OFF;

/* One rate row per vehicle, holding both figures. There is no service on a rate:
       point-to-point  ->  fare = PerKmRate  x road distance
       hourly charter  ->  fare = HourlyRate x hours
   Neither service has a base fare or a minimum, so BaseFare is 0 and is not read by any
   calculation. A rate left NULL is a service that vehicle does not offer, which the booking
   page reports as "Rate unavailable" rather than quoting a price of zero. */
INSERT INTO FareRates (VehicleTypeID, ServiceTypeID, BaseFare, PerKmRate, HourlyRate) VALUES
    (1, 1, 0, 400,  300),
    (2, 1, 0, 500,  500),
    (3, 1, 0, 600,  700),
    (4, 1, 0, 900, 1200);

/* One row per vehicle, so a second rate for the same vehicle cannot be created and the
   booking page can never have to choose between two of them. */
CREATE UNIQUE INDEX UX_FareRates_Vehicle ON FareRates(VehicleTypeID);

SET IDENTITY_INSERT Packages ON;
INSERT INTO Packages (PackageID, Name, DurationDays, FixedPrice, CreatedByDriverID) VALUES
    (1, N'Zwegabin + Saddan Cave Day Tour', 1, 60000, NULL),
    (2, N'Kyauk Ka Lat + Kawgun Cave Tour', 1, 55000, NULL),
    (3, N'Hpa-An Heritage 2-Day Package', 2, 120000, NULL);
SET IDENTITY_INSERT Packages OFF;

SET IDENTITY_INSERT PackagePlaces ON;
INSERT INTO PackagePlaces (PackagePlaceID, PackageID, PlaceName, Lat, Lng, OrderIndex) VALUES
    (1, 1, N'Mount Zwegabin', 16.8550, 97.6561, 1),
    (2, 1, N'Kawgun Cave', 16.7462, 97.6518, 2),
    (3, 1, N'Saddan Cave', 16.6562, 97.6482, 3),
    (4, 2, N'Kyauk Ka Lat Pagoda', 16.9124, 97.7295, 1),
    (5, 2, N'Kawgun Cave', 16.7462, 97.6518, 2),
    (6, 3, N'Thit Hta Nge Waterfall', 16.8072, 97.5738, 1),
    (7, 3, N'Saddan Cave', 16.6562, 97.6482, 2),
    (8, 3, N'Zwegabin', 16.8550, 97.6561, 3);
SET IDENTITY_INSERT PackagePlaces OFF;

/* Supper admin seed (email+password only, KYC n/a).
   Password hash: 7136a4cc23a5f2a1$db11fd6e3b69e597125147f70fea4efcdf4bb8ab760fe2a6f3a4680ff94e8791  == "Admin123!" */
INSERT INTO Admins (FullName, Email, PasswordHash, Role) VALUES
    (N'Super Admin', N'admin@tripway.com', N'7136a4cc23a5f2a1$db11fd6e3b69e597125147f70fea4efcdf4bb8ab760fe2a6f3a4680ff94e8791', N'Super Admin');

PRINT 'TripWayDB schema and seed data created.';
GO