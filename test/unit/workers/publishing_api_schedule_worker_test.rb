require 'test_helper'
require 'gds_api/test_helpers/publishing_api'

class PublishingApiScheduleWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "#publish_intent registers an intent with the publishing api" do
    edition = create(:scheduled_detailed_guide)
    presenter = PublishingApiPresenters.intent_for(edition)
    request = stub_publishing_api_put_intent(presenter.base_path, presenter.as_json)
    PublishingApiScheduleWorker.new.publish_intent(edition, :en)
    assert_requested request
  end

  test "#publish_coming_soon registers a coming_soon format with the publishing api" do
    edition = create(:scheduled_detailed_guide)
    presenter = PublishingApiPresenters.coming_soon_for(edition)
    request = stub_publishing_api_put_item(presenter.base_path, presenter.as_json)
    PublishingApiScheduleWorker.new.publish_coming_soon(edition, :en)
    assert_requested request
  end

  test "#perform calls publish_coming_soon and publish_intent for a new edition" do
    scheduled_edition = create(:scheduled_detailed_guide)
    worker = PublishingApiScheduleWorker.new
    expected_params = responds_with(:id, scheduled_edition.id)
    worker.expects(:publish_intent).with(expected_params, locale)
    worker.expects(:publish_coming_soon).with(expected_params, locale)
    worker.perform(scheduled_edition.class.name, scheduled_edition.id)
  end

  test "#perform does not call publish_intent if there is a published edition" do
    scheduled_edition = create(:scheduled_detailed_guide)
    previous_edition = create(:published_detailed_guide, document: scheduled_edition.document)
    worker = PublishingApiScheduleWorker.new
    worker.expects(:publish_intent).with(responds_with(:id, scheduled_edition.id), locale)
    worker.expects(:publish_coming_soon).never
    worker.perform(scheduled_edition.class.name, scheduled_edition.id)
  end

  def locale
    I18n.default_locale.to_s
  end
end

