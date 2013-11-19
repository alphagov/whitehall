require 'test_helper'

class SafeHtmlValidatorTest < ActiveSupport::TestCase
  def setup
    Whitehall.stubs(:skip_safe_html_validation).returns(false)
    Govspeak::HtmlValidator.stubs(:new).returns(OpenStruct.new(valid?: true))
  end

  def subject
    @subject ||= SafeHtmlValidator.new({})
  end

  test "it should validate each changed attribute with Govspeak::HtmlValidator" do
    test_model = HtmlAttachment.new(body: 'some body text', title: 'some title text', attachable: build(:publication))

    Govspeak::HtmlValidator.expects(:new).with("some body text").returns(OpenStruct.new(valid?: false))
    Govspeak::HtmlValidator.expects(:new).with("some title text").returns(OpenStruct.new(valid?: false))

    subject.validate(test_model)

    assert_equal 2, test_model.errors.count
  end

  test "it should validate that attributes don't include govspeak footnote tags" do
    test_model = Edition.new(body: 'some body text with footnote[^1]')

    subject.validate(test_model)

    assert_equal 1, test_model.errors.count
    assert_equal "cannot include footnotes on this type of document (body includes '[^1]')", test_model.errors.messages[:body].join
  end

  test "it should allow govspeak footnote tags if record responds to :allows_footnotes? with true" do
    test_model = HtmlAttachment.new(body: 'some body text with footnote[^1]')
    test_model.stubs(:allows_footnotes?).returns(true)

    subject.validate(test_model)

    assert_equal 0, test_model.errors.count
  end
end
