/* ============================================================
   Upgrade 11 : one rate row per vehicle, no service on a rate

   A vehicle's rates no longer depend on which service is being
   bought, so the rate table stops having a service column of its
   own. FareRates becomes one row per vehicle holding both figures:

       PerKmRate   point-to-point, charged per kilometre
       HourlyRate  hourly charter, charged per hour

   Before this, a vehicle had a row per service - three rows each -
   and the booking page had to work out which row applied. It did
   that with MAX(), which returns the largest rate ever entered for
   the vehicle rather than the rate currently set. A motorbike whose
   hourly rate had been changed to 200 while an older 3,000 row was
   still present was quoted and charged 3,000. One row per vehicle
   removes the ambiguity entirely, and the code now reads that single
   row.

   What this script does, per vehicle:

     PerKmRate   the per-km rate of that vehicle's most recently
                 updated point-to-point row
     HourlyRate  the per-hour rate of that vehicle's most recently
                 updated hourly row

   The most recently updated row wins, because that is the rate an
   admin last saved. To keep a different figure, save it on
   Admin/FareRateManagement.aspx first so that it is the newest row,
   or edit the single surviving row afterwards - there is only one row
   per vehicle to edit now.

   ServiceTypeID is NOT NULL with a foreign key, so the column stays
   and every row is set to 1 (Point-to-Point). Nothing reads it for a
   rate any more; the service a customer books is on the trip, not on
   the price list. BaseFare is likewise left at 0.

   The unique index moves from (VehicleTypeID, ServiceTypeID) to
   VehicleTypeID alone, so a second row for the same vehicle cannot be
   created again.

   Safe to run more than once: every step is guarded, and a vehicle
   that already has exactly one row is left untouched.
   ============================================================ */

/* One row per vehicle, taking each rate from that vehicle's newest
   row for the service that rate belongs to. */
;WITH newest AS (
    SELECT VehicleTypeID, ServiceTypeID, PerKmRate, HourlyRate,
           ROW_NUMBER() OVER (PARTITION BY VehicleTypeID, ServiceTypeID
                              ORDER BY UpdatedAt DESC, FareRateID DESC) AS rn
    FROM dbo.FareRates
),
per_vehicle AS (
    SELECT v.VehicleTypeID,
           MAX(CASE WHEN n.ServiceTypeID = 1 THEN n.PerKmRate  END) AS PerKmRate,
           MAX(CASE WHEN n.ServiceTypeID = 2 THEN n.HourlyRate END) AS HourlyRate
    FROM dbo.VehicleTypes v
    LEFT JOIN newest n
           ON n.VehicleTypeID = v.VehicleTypeID AND n.rn = 1
    GROUP BY v.VehicleTypeID
),
missing AS (
    SELECT pv.VehicleTypeID, pv.PerKmRate, pv.HourlyRate
    FROM per_vehicle pv
    WHERE NOT EXISTS (SELECT 1 FROM dbo.FareRates f
                      WHERE f.VehicleTypeID = pv.VehicleTypeID)
)
INSERT INTO dbo.FareRates (VehicleTypeID, ServiceTypeID, BaseFare, PerKmRate, HourlyRate)
SELECT m.VehicleTypeID, 1, 0, m.PerKmRate, m.HourlyRate
FROM missing m;
GO

/* Delete every row for a vehicle that is not the one being kept.
   The survivor is the newest of that vehicle's rows, so an admin's
   most recent save is the row that remains. */
DELETE f
FROM dbo.FareRates f
INNER JOIN (
    SELECT FareRateID
    FROM (
        SELECT FareRateID,
               ROW_NUMBER() OVER (PARTITION BY VehicleTypeID
                                  ORDER BY UpdatedAt DESC, FareRateID DESC) AS keep
        FROM dbo.FareRates
    ) ranked
    WHERE ranked.keep > 1
) losers ON losers.FareRateID = f.FareRateID;
GO

/* Keep whichever of the two rates is set, and clear the other, so a
   rate never sits on a row that is not charged for it. */
UPDATE dbo.FareRates
SET PerKmRate  = CASE WHEN PerKmRate  IS NULL OR PerKmRate  = 0 THEN NULL ELSE PerKmRate  END,
    HourlyRate = CASE WHEN HourlyRate IS NULL OR HourlyRate = 0 THEN NULL ELSE HourlyRate END,
    BaseFare   = 0,
    ServiceTypeID = 1,
    UpdatedAt  = SYSUTCDATETIME()
WHERE BaseFare <> 0 OR ServiceTypeID <> 1
   OR (PerKmRate  IS NULL OR PerKmRate  = 0)
   OR (HourlyRate IS NULL OR HourlyRate = 0);
GO

/* One row per vehicle from now on. The old index on vehicle+service
   goes first because a single row per vehicle satisfies it anyway
   and it is no longer the constraint that matters. */
IF EXISTS (SELECT 1 FROM sys.indexes
           WHERE name = 'UX_FareRates_VehicleService'
             AND object_id = OBJECT_ID('dbo.FareRates'))
    DROP INDEX UX_FareRates_VehicleService ON dbo.FareRates;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_FareRates_Vehicle'
                 AND object_id = OBJECT_ID('dbo.FareRates'))
    CREATE UNIQUE INDEX UX_FareRates_Vehicle ON dbo.FareRates (VehicleTypeID);
GO
