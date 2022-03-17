# Naming of files and constants in `lib/patches` is inconsistent with
# Zeitwerk's expectations, so instead we require them all manually and tell
# Zeitwerk to ignore the whole directory.
Dir[Rails.root.join("lib/patches/*.rb")].sort.each do |patch|
  require patch
end

Rails.autoloaders.main.ignore("lib/patches")
