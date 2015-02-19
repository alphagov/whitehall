require "test_helper"

class WorldwidePriorityTest < ActiveSupport::TestCase
  should_allow_image_attachments
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  test 'search_format_types tags the worldwide priority as a worldwide-priority' do
    worldwide_priority = build(:worldwide_priority)
    assert worldwide_priority.search_format_types.include?('worldwide-priority')
  end

  test "should be translatable" do
    assert build(:worldwide_priority).translatable?
  end

  test "is not translatable when non-English" do
    refute build(:worldwide_priority, primary_locale: :es).translatable?
  end
end
