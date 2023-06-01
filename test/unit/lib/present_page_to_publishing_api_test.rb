require "test_helper"

class PresentPageToPublishingApiTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#publish" do
    it "should update content, patch links and publish new document" do
      I18n.with_locale(:cy) do
        presenter = PublishingApi::HowGovernmentWorksPresenter.new
        Services.publishing_api.expects(:put_content).with(presenter.content_id, presenter.content)
        Services.publishing_api.expects(:patch_links).with(presenter.content_id, links: presenter.links)
        Services.publishing_api.expects(:publish).with(presenter.content_id, nil, locale: "cy")
        PresentPageToPublishingApi.new.publish(presenter.class)
      end
    end
  end
end
