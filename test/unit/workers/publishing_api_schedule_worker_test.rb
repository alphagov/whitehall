require 'test_helper'
require 'gds_api/test_helpers/publishing_api'

class PublishingApiScheduleWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

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

private

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
