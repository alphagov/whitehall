require "test_helper"
class PublishPrimeMinistersIndexPageTest < ActiveSupport::TestCase
  setup do
    role = create(:prime_minister_role)
    person = create(:person, forename: "Some", surname: "Person")
    create(:historic_role_appointment, person:, role:, started_at: Date.civil(1950), ended_at: Date.civil(1960))
    create(:historical_account, person:, born: "1900", died: "1975", roles: [role])
  end

  test "sends the page to publishing api" do
    presenter = PublishingApi::HistoricalAccountsIndexPresenter.new
    expected_content = presenter.content

    Services.publishing_api.expects(:put_content).with(presenter.content_id, expected_content)
    Services.publishing_api.expects(:patch_links).with(presenter.content_id, links: presenter.links)
    Services.publishing_api.expects(:publish).with(presenter.content_id, nil)

    PublishPrimeMinistersIndexPage.new.publish
  end
end
