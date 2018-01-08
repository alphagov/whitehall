require "test_helper"

class WipFeaturesTest < ActiveSupport::TestCase
  test "do not commit features tagged work-in-progress" do
    directories = Dir.glob(File.join(Rails.root, 'features', '**', '*.feature'))
    matching_files = directories.select do |filename|
      match = false
      File.open(filename) do |file|
        match = file.grep(%r{@wip}).any?
      end
      match
    end
    assert_equal [], matching_files, %{Avoid leaving features or scenarios tagged with @wip}
  end
end
