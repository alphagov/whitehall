# This migration is to fix the incorrectly formatted timestamps that
# resulted in new migrations appearing in the wrong order.
DataMigrationRecord.find_by(version: "2025030510370000")
  .update!(version: "20250305103700")
DataMigrationRecord.find_by(version: "2025040311460000")
  .update!(version: "20250403114600")
DataMigrationRecord.find_by(version: "2025042311160000")
  .update!(version: "20250423111600")
