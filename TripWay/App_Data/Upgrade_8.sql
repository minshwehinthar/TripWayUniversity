/* ============================================================
   Upgrade 8 : VIP van seats 1-10, not 5-10

   The VIP van was seeded with MinSeatCapacity = 5, so both the seat
   range on its vehicle card and the passenger list stopped at five:
   a customer could not book the van for fewer than five people, and
   the list read "5, 6, 7, 8, 9, 10" instead of 1 to 10.

   The passenger picker is meant to offer every number the van can
   carry, 1 to 10, so the minimum is 1. The maximum is untouched, and
   the other vehicle classes are left exactly as they are.

   To go back to selling the van for five or more only, set
   MinSeatCapacity = 5 for that row again.
   ============================================================ */

UPDATE dbo.VehicleTypes
SET MinSeatCapacity = 1
WHERE Name = N'VIP Van' AND MinSeatCapacity <> 1;
GO
