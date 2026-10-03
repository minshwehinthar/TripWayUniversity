/* ============================================================
   TripWayDB — idempotent auto-apply script (runs on app start
   via Helper.DatabaseUpgrader once the TripWayDB database exists).
   Re-runs safely: every statement is guarded with IF NOT EXISTS.
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'VehicleTypes')
BEGIN
    CREATE TABLE VehicleTypes (
        VehicleTypeID INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(50) NOT NULL,
        MinSeatCapacity INT NOT NULL,
        MaxSeatCapacity INT NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ServiceTypes')
BEGIN
    CREATE TABLE ServiceTypes (
        ServiceTypeID INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(50) NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Customers')
BEGIN
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
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Drivers')
BEGIN
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
        PaymentAccount NVARCHAR(150) NULL,
        KYCStatus NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        IsOnline BIT NOT NULL DEFAULT 0,
        CurrentLat DECIMAL(9,6) NULL,
        CurrentLng DECIMAL(9,6) NULL,
        AverageRating DECIMAL(3,2) NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Admins')
BEGIN
    CREATE TABLE Admins (
        AdminID INT IDENTITY(1,1) PRIMARY KEY,
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(150) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(256) NOT NULL,
        Role NVARCHAR(30) NOT NULL DEFAULT 'Admin',
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Packages')
BEGIN
    CREATE TABLE Packages (
        PackageID INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(150) NOT NULL,
        DurationDays INT NOT NULL,
        FixedPrice DECIMAL(12,2) NOT NULL,
        CreatedByDriverID INT NULL FOREIGN KEY REFERENCES Drivers(DriverID),
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PackagePlaces')
BEGIN
    CREATE TABLE PackagePlaces (
        PackagePlaceID INT IDENTITY(1,1) PRIMARY KEY,
        PackageID INT NOT NULL FOREIGN KEY REFERENCES Packages(PackageID),
        PlaceName NVARCHAR(150) NOT NULL,
        Lat DECIMAL(9,6) NOT NULL,
        Lng DECIMAL(9,6) NOT NULL,
        OrderIndex INT NOT NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FareRates')
BEGIN
    CREATE TABLE FareRates (
        FareRateID INT IDENTITY(1,1) PRIMARY KEY,
        VehicleTypeID INT NOT NULL FOREIGN KEY REFERENCES VehicleTypes(VehicleTypeID),
        ServiceTypeID INT NOT NULL FOREIGN KEY REFERENCES ServiceTypes(ServiceTypeID),
        BaseFare DECIMAL(12,2) NOT NULL,
        PerKmRate DECIMAL(12,2) NULL,
        HourlyRate DECIMAL(12,2) NULL,
        UpdatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Trips')
BEGIN
    CREATE TABLE Trips (
        TripID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
        DriverID INT NULL FOREIGN KEY REFERENCES Drivers(DriverID),
        VehicleTypeID INT NOT NULL FOREIGN KEY REFERENCES VehicleTypes(VehicleTypeID),
        ServiceTypeID INT NOT NULL FOREIGN KEY REFERENCES ServiceTypes(ServiceTypeID),
        PackageID INT NULL FOREIGN KEY REFERENCES Packages(PackageID),
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
        PaymentStatus NVARCHAR(20) NOT NULL DEFAULT 'Unpaid'
    );
    CREATE INDEX IX_Trips_Customer ON Trips(CustomerID);
    CREATE INDEX IX_Trips_Driver ON Trips(DriverID);
    CREATE INDEX IX_Trips_Status ON Trips(Status, VehicleTypeID);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TripGPSLogs')
BEGIN
    CREATE TABLE TripGPSLogs (
        LogID BIGINT IDENTITY(1,1) PRIMARY KEY,
        TripID INT NOT NULL FOREIGN KEY REFERENCES Trips(TripID),
        Lat DECIMAL(9,6) NOT NULL,
        Lng DECIMAL(9,6) NOT NULL,
        RecordedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_TripGPSLogs_Trip ON TripGPSLogs(TripID);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Payments')
BEGIN
    CREATE TABLE Payments (
        PaymentID INT IDENTITY(1,1) PRIMARY KEY,
        TripID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Trips(TripID),
        Amount DECIMAL(12,2) NOT NULL,
        Method NVARCHAR(20) NOT NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        PaidAt DATETIME2 NULL
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ChatMessages')
BEGIN
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
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Ratings')
BEGIN
    CREATE TABLE Ratings (
        RatingID INT IDENTITY(1,1) PRIMARY KEY,
        TripID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Trips(TripID),
        CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
        DriverID INT NOT NULL FOREIGN KEY REFERENCES Drivers(DriverID),
        Score INT NOT NULL CHECK (Score BETWEEN 1 AND 5),
        Comment NVARCHAR(500) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ActivityLogs')
BEGIN
    CREATE TABLE ActivityLogs (
        LogID BIGINT IDENTITY(1,1) PRIMARY KEY,
        TripID INT NULL FOREIGN KEY REFERENCES Trips(TripID),
        EventType NVARCHAR(50) NOT NULL,
        Details NVARCHAR(500) NULL,
        RecordedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_ActivityLogs_Trip ON ActivityLogs(TripID);
END
GO

/* ---------- seed data (idempotent) ---------- */

IF NOT EXISTS (SELECT 1 FROM VehicleTypes)
BEGIN
    INSERT INTO VehicleTypes (Name, MinSeatCapacity, MaxSeatCapacity) VALUES
        (N'Motorbike', 1, 1),
        (N'Tuk-Tuk', 1, 4),
        (N'Saloon', 1, 4),
        (N'VIP Van', 1, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM ServiceTypes)
BEGIN
    INSERT INTO ServiceTypes (Name) VALUES
        (N'Point-to-Point'), (N'Hourly'), (N'Package');
END
GO

IF NOT EXISTS (SELECT 1 FROM FareRates)
BEGIN
    INSERT INTO FareRates (VehicleTypeID, ServiceTypeID, BaseFare, PerKmRate, HourlyRate) VALUES
        (1, 1, 1000, 400, NULL), (1, 2, 1000, NULL, 6000), (1, 3, 0, NULL, NULL),
        (2, 1, 2000, 500, NULL), (2, 2, 2000, NULL, 8000), (2, 3, 0, NULL, NULL),
        (3, 1, 3000, 600, NULL), (3, 2, 3000, NULL, 12000), (3, 3, 0, NULL, NULL),
        (4, 1, 5000, 900, NULL), (4, 2, 5000, NULL, 18000), (4, 3, 0, NULL, NULL);
END
GO

IF NOT EXISTS (SELECT 1 FROM Packages)
BEGIN
    INSERT INTO Packages (Name, DurationDays, FixedPrice, CreatedByDriverID) VALUES
        (N'Zwegabin + Saddan Cave Day Tour', 1, 60000, NULL),
        (N'Kyauk Ka Lat + Kawgun Cave Tour', 1, 55000, NULL),
        (N'Hpa-An Heritage 2-Day Package', 2, 120000, NULL);
END
GO

IF NOT EXISTS (SELECT 1 FROM PackagePlaces)
BEGIN
    INSERT INTO PackagePlaces (PackageID, PlaceName, Lat, Lng, OrderIndex) VALUES
        (1, N'Mount Zwegabin', 16.8550, 97.6561, 1),
        (1, N'Kawgun Cave', 16.7462, 97.6518, 2),
        (1, N'Saddan Cave', 16.6562, 97.6482, 3),
        (2, N'Kyauk Ka Lat Pagoda', 16.9124, 97.7295, 1),
        (2, N'Kawgun Cave', 16.7462, 97.6518, 2),
        (3, N'Thit Hta Nge Waterfall', 16.8072, 97.5738, 1),
        (3, N'Saddan Cave', 16.6562, 97.6482, 2),
        (3, N'Zwegabin', 16.8550, 97.6561, 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM Admins)
BEGIN
    INSERT INTO Admins (FullName, Email, PasswordHash, Role) VALUES
        (N'Super Admin', N'admin@tripway.com',
         N'7136a4cc23a5f2a1$db11fd6e3b69e597125147f70fea4efcdf4bb8ab760fe2a6f3a4680ff94e8791',
         N'Super Admin');
END
GO

PRINT 'TripWayDB upgrade 1 applied.';
GO