require "test_helper"

class InternationalPriorityTest < ActiveSupport::TestCase
  should_allow_image_attachments
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  test 'search_format_types tags the international priority as an international-priority' do
    international_priority = build(:international_priority)
    assert international_priority.search_format_types.include?('international-priority')
  end
end
