/* ============================================================
   Upgrade 12 : hide a package without deleting it

   Every package was always bookable. Deleting was the only way to
   take one off the booking page, and deleting also throws away its
   places, gallery photos and any trips that referenced it. A
   package that is finished for the season still had to be kept
   visible, or had to be deleted and later rebuilt by hand.

   This adds Packages.IsActive, matching the flag Hotels already
   has. An admin can now hide a package on PackageManagement.aspx:
   it disappears from the customer booking page and the home page
   but its data, photos and history stay exactly as they were, and
   it can be brought back with one click.

   Existing packages are all set to active, so nothing disappears
   from the booking page just because this script ran.

   Safe to run more than once: the column add is guarded.
   ============================================================ */

IF COL_LENGTH('dbo.Packages', 'IsActive') IS NULL
    ALTER TABLE dbo.Packages ADD IsActive BIT NOT NULL DEFAULT 1;
GO
