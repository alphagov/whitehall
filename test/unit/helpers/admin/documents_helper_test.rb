require "test_helper"

class Admin::DocumentsHelperTest < ActionView::TestCase
  test "should return nil for humanized content type when file extension is nil" do
    assert_nil humanized_content_type(nil)
  end

  test "should return PDF Document for humanized content type" do
    assert_equal "PDF Document", humanized_content_type("pdf")
    assert_equal "PDF Document", humanized_content_type("PDF")
  end

  test "should return CSV Document for humanized content type" do
    assert_equal "CSV Document", humanized_content_type("csv")
  end

  test "should return RTF Document for humanized content type" do
    assert_equal "RTF Document", humanized_content_type("rtf")
  end

  test "should return PNG Image for humanized content type" do
    assert_equal "PNG Image", humanized_content_type("png")
  end

  test "should return JPEG Document for humanized content type" do
    assert_equal "JPEG Document", humanized_content_type("jpg")
  end

  test "should return MS Word Document for humanized content type" do
    assert_equal "MS Word Document", humanized_content_type("doc")
    assert_equal "MS Word Document", humanized_content_type("docx")
  end

  test "should return MS Excel Spreadsheet for humanized content type" do
    assert_equal "MS Excel Spreadsheet", humanized_content_type("xls")
    assert_equal "MS Excel Spreadsheet", humanized_content_type("xlsx")
  end

  test "should return MS Powerpoint Presentation for humanized content type" do
    assert_equal "MS Powerpoint Presentation", humanized_content_type("ppt")
    assert_equal "MS Powerpoint Presentation", humanized_content_type("pptx")
  end
end
