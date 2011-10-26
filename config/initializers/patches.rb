Dir[Rails.root.join("lib", "patches", "*.rb")].each do |patch|
  require patch
end