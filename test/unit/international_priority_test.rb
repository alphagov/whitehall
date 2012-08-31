require "test_helper"

class InternationalPriorityTest < EditionTestCase
  should_allow_image_attachments
  should_not_allow_a_summary_to_be_written
end