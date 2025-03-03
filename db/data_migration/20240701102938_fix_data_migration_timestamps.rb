# This migration is to fix the incorrectly formatted timestamps that
# resulted in new migrations appearing in the wrong order.
DataMigrationRecord.find_by(version: "202407101125900")
  .update!(version: "20240710112590")
DataMigrationRecord.find_by(version: "202407121629400")
  .update!(version: "20240712162940")
DataMigrationRecord.find_by(version: "202408151644400")
  .update!(version: "20240815164440")
DataMigrationRecord.find_by(version: "2024121711524600")
  .update!(version: "20241217115246")
DataMigrationRecord.find_by(version: "202501231521000")
  .update!(version: "20250123152100")
