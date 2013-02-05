require "test_helper"

class InternationalPriorityTest < ActiveSupport::TestCase
  should_allow_image_attachments
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note
end
