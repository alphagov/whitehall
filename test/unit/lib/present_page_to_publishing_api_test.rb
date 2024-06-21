require "test_helper"
class PresentPageToPublishingApiTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#publish" do
    it "send the fields of operation index page to publishing api" do
      assert_content_is_presented_to_publishing_api(PublishingApi::OperationalFieldsIndexPresenter)
    end

    it "sends the past prime ministers index page to publishing api" do
      role = create(:prime_minister_role)
      person = create(:person, forename: "Some", surname: "Person")
      create(:historic_role_appointment, person:, role:, started_at: Date.civil(1950), ended_at: Date.civil(1960))
      create(:historical_account, person:, born: "1900", died: "1975", role:)

      assert_content_is_presented_to_publishing_api(PublishingApi::HistoricalAccountsIndexPresenter)
    end

    it "should update content, patch links and publish new document with locale" do
      I18n.with_locale(:cy) do
        assert_content_is_presented_to_publishing_api(PublishingApi::HowGovernmentWorksPresenter, locale: "cy")
      end
    end

    it "sends the world index page to publishing api" do
      assert_content_is_presented_to_publishing_api(PublishingApi::WorldIndexPresenter)
    end
  end

  describe "#patch_links" do
    it "patches links" do
      presenter_class = PublishingApi::OperationalFieldsIndexPresenter

      Services.publishing_api.expects(:patch_links).with(presenter_class.new.content_id, links: presenter_class.new.links)

      PresentPageToPublishingApi.new.patch_links(presenter_class)
    end
  end

  describe "#save_draft" do
    it "saves the operation index page to publishing api draft stack" do
      assert_content_is_presented_to_publishing_api_draft_stack(PublishingApi::OperationalFieldsIndexPresenter)
    end
  end

  def assert_content_is_presented_to_publishing_api(presenter_class, locale: "en")
    presenter = presenter_class.new
    expected_content = presenter.content

    Services.publishing_api.expects(:put_content).with(presenter.content_id, expected_content)
    Services.publishing_api.expects(:patch_links).with(presenter.content_id, links: presenter.links)
    Services.publishing_api.expects(:publish).with(presenter.content_id, nil, locale:)

    PresentPageToPublishingApi.new.publish(presenter_class)
  end

  def assert_content_is_presented_to_publishing_api_draft_stack(presenter_class, locale: "en")
    presenter = presenter_class.new
    expected_content = presenter.content

    Services.publishing_api.expects(:put_content).with(presenter.content_id, expected_content).once
    Services.publishing_api.expects(:patch_links).with(presenter.content_id, links: presenter.links).once
    Services.publishing_api.expects(:publish).with(presenter.content_id, nil, locale:).never

    PresentPageToPublishingApi.new.save_draft(presenter_class)
  end
end
