require 'test_helper'
require_relative '../importer_test_logger'

class Whitehall::Uploader::Finders::RoleAppointmentsFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = ImporterTestLogger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the appointments occupied by the ministers identified by slug at the date specified" do
    minister = create(:person)
    role = create(:ministerial_role)
    appointment = create(:role_appointment, role: role, person: minister, started_at: 6.months.ago)
    assert_equal [appointment], Whitehall::Uploader::Finders::RoleAppointmentsFinder.find(1.month.ago, minister.slug, @log, @line_number)
  end

  test "ignores blank slugs" do
    assert_equal [], Whitehall::Uploader::Finders::RoleAppointmentsFinder.find(1.day.ago, '', @log, @line_number)
  end

  test "logs a warning if a person can't be found for the given slug" do
    Whitehall::Uploader::Finders::RoleAppointmentsFinder.find(1.day.ago, 'made-up-person-slug', @log, @line_number)
    assert_match /Unable to find Person with slug 'made-up-person-slug'/, @log_buffer.string
  end

  test "logs a warning if the person we find didn't have a role on the date specified" do
    person = create(:person)
    Whitehall::Uploader::Finders::RoleAppointmentsFinder.find(Date.today, person.slug, @log, @line_number)
    assert_match /Unable to find an appointment for '#{person.slug}' at '#{Date.today}'/, @log_buffer.string
  end
end
