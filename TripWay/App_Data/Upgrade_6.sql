/* ============================================================
   Upgrade 6 : driver profile photo
   Drivers had no face-photo column, only KYC document photos
   (NRC / licence / registration), which must never be published
   on a public page. This adds a dedicated, admin-managed
   profile photo that is safe to show on About Us.
   ============================================================ */

IF COL_LENGTH('dbo.Drivers', 'ProfilePhotoUrl') IS NULL
    ALTER TABLE dbo.Drivers ADD ProfilePhotoUrl NVARCHAR(300) NULL;
GO
