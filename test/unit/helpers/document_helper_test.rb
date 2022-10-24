require "test_helper"

class DocumentHelperTest < ActionView::TestCase
  include PublicDocumentRoutesHelper
  include OrganisationHelper
  include InlineSvg::ActionView::Helpers

  test "should return nil for humanized content type when file extension is nil" do
    assert_nil humanized_content_type(nil)
  end

  test "#attachment_thumbnail returns document thumbnails with public URLs for .doc files" do
    attachment = create(:file_attachment, file: upload_fixture("sample.docx", "application/msword"))
    assert_match inline_svg_tag("attachment-icons/document.svg", aria_hidden: true), attachment_thumbnail(attachment)
  end

  test "#attachment_thumbnail returns spreadsheet thumbnails with public URLs for spreadsheet files" do
    attachment = create(:file_attachment, file: upload_fixture("sample-from-excel.csv", "text/csv"))
    assert_match inline_svg_tag("attachment-icons/spreadsheet.svg", aria_hidden: true), attachment_thumbnail(attachment)
  end

  test "#attachment_thumbnail returns HTML thumbnails with public URLs for HTML attachments" do
    publication = create(:published_publication, :with_html_attachment)
    assert_match inline_svg_tag("attachment-icons/html.svg", aria_hidden: true), attachment_thumbnail(publication.attachments.first)
  end

  test "#attachment_thumbnail returns generic thumbnails with public URLs for other files" do
    attachment = create(:file_attachment, file: upload_fixture("sample_attachment.zip", "application/zip"))
    assert_match inline_svg_tag("attachment-icons/generic.svg", aria_hidden: true), attachment_thumbnail(attachment)
  end

  test "should return PDF Document for humanized content type" do
    assert_equal '<abbr title="Portable Document Format">PDF</abbr>', humanized_content_type("pdf")
    assert_equal '<abbr title="Portable Document Format">PDF</abbr>', humanized_content_type("PDF")
  end

  test "should return CSV Document for humanized content type" do
    assert_equal '<abbr title="Comma-separated Values">CSV</abbr>', humanized_content_type("csv")
  end

  test "should return RTF Document for humanized content type" do
    assert_equal '<abbr title="Rich Text Format">RTF</abbr>', humanized_content_type("rtf")
  end

  test "should return PNG Image for humanized content type" do
    assert_equal '<abbr title="Portable Network Graphic">PNG</abbr>', humanized_content_type("png")
  end

  test "should return JPEG Document for humanized content type" do
    assert_equal "JPEG", humanized_content_type("jpg")
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

  test "should return Zip archive for humanized content type" do
    assert_equal '<abbr title="Zip archive">ZIP</abbr>', humanized_content_type("zip")
  end

  test "should return XML for humanized content type" do
    assert_equal '<abbr title="XML document">XML</abbr>', humanized_content_type("xml")
  end

  test "should return native language name for locale" do
    assert_equal "English", native_language_name_for(:en)
    assert_equal "Español", native_language_name_for(:es)
  end

  test "#link_to_translation should generate a link based on the current controller action with the given locale" do
    controller.stubs(:url_options).returns(
      action: "show",
      controller: "worldwide_organisations",
      locale: "de",
      id: "a-world-organisation",
    )
    assert_dom_equal %(<a lang="de" class="govuk-link" href="/world/organisations/a-world-organisation.de">Deutsch</a>),
                     link_to_translation(:de)
  end

  test "#link_to_translation should not suffix URLs with 'en'" do
    controller.stubs(:url_options).returns(
      action: "show",
      controller: "worldwide_organisations",
      locale: "it",
      id: "a-world-organisation",
    )
    assert_dom_equal %(<a lang="en"  class="govuk-link" href="/world/organisations/a-world-organisation">English</a>),
                     link_to_translation(:en)
  end
end
