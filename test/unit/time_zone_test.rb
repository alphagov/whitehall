require 'test_helper'

class TimeZoneTest < ActiveSupport::TestCase
  test "only use instances of TimeWithZone, not instances of Time" do
    directories = Dir.glob(File.join(Rails.root, '**', '*.rb'))
    matching_files = directories.select do |filename|
      match = false
      File.open(filename) do |file|
        match = file.grep(%r{Time\.(now|utc|parse)}).any?
      end
      match
    end
    assert_equal [], matching_files - [File.expand_path(__FILE__)], %{Avoid issues with daylight-savings time by always building instances of TimeWithZone and not Time. Use methods like Time.zone.now, Time.zone.parse, n.days.ago, m.hours.from_now, etc in preference to methods like Time.now, Time.utc, Time.parse, etc.}
  end
end
