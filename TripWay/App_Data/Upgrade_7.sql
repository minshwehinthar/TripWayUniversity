/* ============================================================
   Upgrade 7 : hourly charter priced as minimum + extra hours

   Hourly hire used to be charged as BaseFare + HourlyRate * hours,
   which made the first hour cost an extra hourly rate and pushed
   every block well above the published list.

   The published list is a minimum first hour plus a charge for every
   hour after it, and it never moves with distance:

       fare = BaseFare + HourlyRate * (hours - 1)

   With BaseFare 4,000 and HourlyRate 3,000 the bookable blocks price
   as 1h 4,000 / 2h 7,000 / 3h 10,000 / 4h 13,000 / 5h 16,000 /
   6h 19,000 / 8h 25,000, which is the list the booking page shows.

   Hourly rows are set to those two numbers. PerKmRate is forced to
   NULL so an hourly fare can never pick up a mileage component.
   Rows for other services are left exactly as they are.
   ============================================================ */

UPDATE dbo.FareRates
SET BaseFare   = 4000,
    PerKmRate  = NULL,
    HourlyRate = 3000,
    UpdatedAt  = SYSUTCDATETIME()
WHERE ServiceTypeID = 2;
GO
