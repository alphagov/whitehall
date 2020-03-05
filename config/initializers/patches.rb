Dir[Rails.root.join("lib/patches/*.rb")].sort.each do |patch|
  require patch
end
