require 'test_helper'
require_relative '../importer_test_logger'

class Whitehall::Uploader::Finders::OrganisationFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = ImporterTestLogger.new(@log_buffer)
    @line_number = 1
    @default_organisation = create(:organisation)
  end

  test "returns a single element array containing the organisation identified by name" do
    organisation = create(:organisation)
    assert_equal [organisation], Whitehall::Uploader::Finders::OrganisationFinder.find(organisation.name, @log, @line_number, @default_organisation)
  end

  test "returns a single element array containing the organisation identified by slug" do
    organisation = create(:organisation)
    assert_equal [organisation], Whitehall::Uploader::Finders::OrganisationFinder.find(organisation.slug, @log, @line_number, @default_organisation)
  end

  test "returns the supplied default organisation if the name is blank" do
    assert_equal [@default_organisation], Whitehall::Uploader::Finders::OrganisationFinder.find('', @log, @line_number, @default_organisation)
  end

  test "doesn't log a warning if name is blank" do
    Whitehall::Uploader::Finders::OrganisationFinder.find('', @log, @line_number, @default_organisation)
    assert_equal '', @log_buffer.string
  end

  test "returns an empty array if the organisation can't be found" do
    assert_equal [], Whitehall::Uploader::Finders::OrganisationFinder.find('made-up-organisation-name', @log, @line_number, @default_organisation)
  end

  test "logs a warning if the organisation can't be found" do
    Whitehall::Uploader::Finders::OrganisationFinder.find('made-up-organisation-name', @log, @line_number, @default_organisation)
    assert_match /Unable to find Organisation named 'made-up-organisation-name'/, @log_buffer.string
  end
end
