require File.expand_path("../../../test/factories", __FILE__)

def image_fixture_file
  @_image_fixture_file ||= File.open(Rails.root.join('test', 'fixtures', 'minister-of-funk.960x640.jpg'))
end

World(FactoryGirl::Syntax::Methods)
