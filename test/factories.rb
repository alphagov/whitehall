def image_fixture_file
  @image_fixture_file ||= File.open(Rails.root.join('test/fixtures/minister-of-funk.960x640.jpg'))
end

Dir[Rails.root.join('test/factories/*.rb')].each { |f| require f }
