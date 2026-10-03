IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TripStops')
BEGIN
    CREATE TABLE TripStops (
        TripStopID INT IDENTITY(1,1) PRIMARY KEY,
        TripID INT NOT NULL FOREIGN KEY REFERENCES Trips(TripID),
        Lat DECIMAL(9,6) NOT NULL,
        Lng DECIMAL(9,6) NOT NULL,
        Address NVARCHAR(300) NULL,
        OrderIndex INT NOT NULL
    );
    CREATE INDEX IX_TripStops_TripID ON TripStops(TripID);
END
GO