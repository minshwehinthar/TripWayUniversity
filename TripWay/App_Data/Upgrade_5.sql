/* ============================================================
   TripWayDB — hotels.
   Hotels      : partner hotels the customer can book a transfer to.
   Trips.HotelID: set when the destination is a hotel, so the driver
                  and the trip detail pages can show which hotel.
   Re-runs safely: every statement is guarded.
   ============================================================ */

IF OBJECT_ID('dbo.Hotels', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Hotels (
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

    CREATE INDEX IX_Hotels_Active ON dbo.Hotels(IsActive, Name);
END
GO

IF COL_LENGTH('dbo.Trips', 'HotelID') IS NULL
    ALTER TABLE dbo.Trips ADD HotelID INT NULL
        CONSTRAINT FK_Trips_Hotels FOREIGN KEY REFERENCES dbo.Hotels(HotelID);
GO

IF OBJECT_ID('dbo.Hotels', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Trips_Hotel' AND object_id = OBJECT_ID('dbo.Trips'))
    CREATE INDEX IX_Trips_Hotel ON dbo.Trips(HotelID);
GO
