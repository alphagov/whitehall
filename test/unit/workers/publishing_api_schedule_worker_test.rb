require 'test_helper'
require 'gds_api/test_helpers/publishing_api'

class PublishingApiScheduleWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "#publish_intent registers an intent with the publishing api" do
    edition = create(:scheduled_detailed_guide)
    presenter = PublishingApiPresenters.publish_intent_for(edition)
    request = stub_publishing_api_put_intent(presenter.base_path, presenter.as_json)
    schedule_worker(edition, locale).publish_intent
    assert_requested request
  end

  test "#publish_coming_soon registers a coming_soon format with the publishing api" do
    edition = create(:scheduled_detailed_guide)
    presenter = PublishingApiPresenters.coming_soon_for(edition)
    request = stub_publishing_api_put_item(presenter.base_path, presenter.as_json)
    schedule_worker(edition, locale).publish_coming_soon
    assert_requested request
  end

  test "#perform publishes a publish intent and a coming_soon content item for a new edition" do
    stub_default_publishing_api_put_intent
    scheduled_edition = create(:scheduled_detailed_guide)
    path = Whitehall.url_maker.public_document_path(scheduled_edition)
    PublishingApiScheduleWorker.new.perform(scheduled_edition.class.name, scheduled_edition.id)

    assert_publishing_api_put_intent(path, publish_time: scheduled_edition.scheduled_publication.as_json)
    assert_publishing_api_put_item(path, format: 'coming_soon')
  end

  test "#perform publishes a publish intent but no coming_soon item when the document has previously been published" do
    stub_default_publishing_api_put_intent
    scheduled_edition = create(:scheduled_detailed_guide)
    path = Whitehall.url_maker.public_document_path(scheduled_edition)
    previous_edition = create(:published_detailed_guide, document: scheduled_edition.document)
    PublishingApiScheduleWorker.new.perform(scheduled_edition.class.name, scheduled_edition.id)

    assert_publishing_api_put_intent(path, publish_time: scheduled_edition.scheduled_publication.as_json)
    assert_not_requested(:put, %r{#{PUBLISHING_API_ENDPOINT}/content.*})
  end

  def locale
    I18n.default_locale.to_s
  end

  def schedule_worker(model, locale=nil)
    PublishingApiScheduleWorker.new.tap do |w|
      w.model = model
      w.locale = locale
    end
  end

end

