require "test_helper"

class ExternalAttachmentTest < ActiveSupport::TestCase
  test "component params for External attachment" do
    attachment = create(:external_attachment)
    expect_params = {
      type: "external",
      title: attachment.title,
      url: attachment.url,
    }
    assert_equal expect_params, attachment.publishing_component_params
  end
end
