require "test_helper"

class FatalityNoticeTest < EditionTestCase
  should_allow_image_attachments
  should_allow_a_summary_to_be_written
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note
end
