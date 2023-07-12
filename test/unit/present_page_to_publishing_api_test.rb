require "test_helper"
class PresentPageToPublishingApiTest < ActiveSupport::TestCase
  test "send the fields of operation index page to publishing api" do
    assert_content_is_presented_to_publishing_api(PublishingApi::OperationalFieldsIndexPresenter)
  end

  test "sends the how government works page to publishing api" do
    assert_content_is_presented_to_publishing_api(PublishingApi::HowGovernmentWorksPresenter)
  end

  test "sends the past prime ministers index page to publishing api" do
    role = create(:prime_minister_role)
    person = create(:person, forename: "Some", surname: "Person")
    create(:historic_role_appointment, person:, role:, started_at: Date.civil(1950), ended_at: Date.civil(1960))
    create(:historical_account, person:, born: "1900", died: "1975", roles: [role])

    assert_content_is_presented_to_publishing_api(PublishingApi::HistoricalAccountsIndexPresenter)
  end

  test "should update content, patch links and publish new document with locale" do
    I18n.with_locale(:cy) do
      assert_content_is_presented_to_publishing_api(PublishingApi::HowGovernmentWorksPresenter, locale: "cy")
    end
  end

  test "sends the world index page to publishing api" do
    assert_content_is_presented_to_publishing_api(PublishingApi::WorldIndexPresenter)
  end

  def assert_content_is_presented_to_publishing_api(presenter_class, locale: "en")
    presenter = presenter_class.new
    expected_content = presenter.content

    Services.publishing_api.expects(:put_content).with(presenter.content_id, expected_content)
    Services.publishing_api.expects(:patch_links).with(presenter.content_id, links: presenter.links)
    Services.publishing_api.expects(:publish).with(presenter.content_id, nil, locale:)

    PresentPageToPublishingApi.new.publish(presenter_class)
  end
end
