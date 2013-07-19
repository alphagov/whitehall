require 'csv'

CSV.read('db/data_migration/20130218111729_add_missing_iso2_codes.csv', headers: false, encoding: "UTF-8").each do |row|
  name, iso2 = row
  WorldLocation.find_by_name!(name).update_column(:iso2, iso2)
end
