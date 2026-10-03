/* ============================================================
   TripWayDB — driver arrival ETA (set when a driver accepts a request).
   EtaMinutes  : minutes the driver estimated to reach the pickup point.
   EtaSetAt    : UTC timestamp when that estimate was given (countdown anchor).
   Re-runs safely: every statement is guarded with COL_LENGTH.
   ============================================================ */

IF COL_LENGTH('dbo.Trips', 'EtaMinutes') IS NULL
    ALTER TABLE dbo.Trips ADD EtaMinutes INT NULL;
GO

IF COL_LENGTH('dbo.Trips', 'EtaSetAt') IS NULL
    ALTER TABLE dbo.Trips ADD EtaSetAt DATETIME2 NULL;
GO
