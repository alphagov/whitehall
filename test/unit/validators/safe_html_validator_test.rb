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
end
