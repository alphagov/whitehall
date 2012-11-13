require 'test_helper'

class ConsultationResponseFormUploaderTest < ActiveSupport::TestCase
  test "should only allow RTF, CSV, Word, Excel or PDF images" do
    uploader = ConsultationResponseFormUploader.new
    assert_same_elements %w(rtf csv doc docx xls xlsx pdf), uploader.extension_white_list
  end
end
