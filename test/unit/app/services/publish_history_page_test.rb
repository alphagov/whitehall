require "test_helper"

class PublishHistoryPageTest < ActiveSupport::TestCase
  test "it uses the provided content id when publishing" do
    ten_ds_page = YAML.load(File.read("lib/history_pages/10_downing_street.yaml"))

    PublishHistoryPage.call(ten_ds_page.to_h)

    assert_publishing_api_put_content("14aa298f-03a8-4e76-96de-483efa3d001f", ten_ds_page.history_page_content_item)
    assert_publishing_api_publish("14aa298f-03a8-4e76-96de-483efa3d001f")
  end

  # TODO: Some reasonable tests:
  # Did it extract the headers correctly?
  # Is the HTML okayish?
  # What are we going to do about the images?
end
