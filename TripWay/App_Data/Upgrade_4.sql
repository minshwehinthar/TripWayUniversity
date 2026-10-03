/* ============================================================
   TripWayDB — package photos.
   CoverPhotoUrl : main package image shown on lists and the detail page.
   PackagePhotos : extra gallery images for a package.
   Re-runs safely: every statement is guarded.
   ============================================================ */

IF COL_LENGTH('dbo.Packages', 'CoverPhotoUrl') IS NULL
    ALTER TABLE dbo.Packages ADD CoverPhotoUrl NVARCHAR(300) NULL;
GO

IF OBJECT_ID('dbo.PackagePhotos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PackagePhotos (
        PackagePhotoID INT IDENTITY(1,1) PRIMARY KEY,
        PackageID INT NOT NULL FOREIGN KEY REFERENCES dbo.Packages(PackageID),
        PhotoUrl NVARCHAR(300) NOT NULL,
        SortOrder INT NOT NULL DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );

    CREATE INDEX IX_PackagePhotos_Package ON dbo.PackagePhotos(PackageID, SortOrder);
END
GO
