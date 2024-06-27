def image_fixture_file
  @image_fixture_file ||= File.open(Rails.root.join("test/fixtures/minister-of-funk.960x640.jpg"))
end

[
  Dir[Rails.root.join("test/factories/*.rb")],
  Dir[Rails.root.join("lib/engines/**/test/factories/*.rb")],
].flatten.sort.each { |f| require f }
