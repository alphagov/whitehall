require "test_helper"
class PublishHowGovernmentWorksPageTest < ActiveSupport::TestCase
  test "sends the page to publishing api" do
    presenter = PublishingApi::HowGovernmentWorksPresenter.new
    expected_content = presenter.content

    Services.publishing_api.expects(:put_content).with(presenter.content_id, expected_content)
    Services.publishing_api.expects(:patch_links).with(presenter.content_id, links: presenter.links)
    Services.publishing_api.expects(:publish).with(presenter.content_id, nil)

    PublishHowGovernmentWorksPage.new.publish
  end
end
