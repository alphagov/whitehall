require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  test "registers an edition with the publishing api" do
    create(:government)
    edition = create(:published_detailed_guide)
    presenter = PublishingApiPresenters.presenter_for(edition)
    requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, update_type: nil, locale: "en")
    ]

    PublishingApiWorker.new.perform(edition.class.name, edition.id)

    assert_all_requested(requests)
  end

  test "registers case studies with their own presenter" do
    edition = create(:published_case_study)
    presenter = PublishingApiPresenters.presenter_for(edition)
    requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, update_type: nil, locale: "en")
    ]

    PublishingApiWorker.new.perform(edition.class.name, edition.id)

    requests.each { |request| assert_requested request }
  end

  test "registers an organisation with the publishing api" do
    disable_publishes_to_publishing_api do
      organisation = create(:organisation)
      presenter = PublishingApiPresenters.presenter_for(organisation)

      requests = [
        stub_publishing_api_put_content(presenter.content_id, presenter.content),
        stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
        stub_publishing_api_publish(presenter.content_id, update_type: nil, locale: "en")
      ]

      PublishingApiWorker.new.perform(organisation.class.name, organisation.id)

      requests.each { |request| assert_requested request }
    end
  end

  test "fails gracefully if the model cannot be found" do
    non_existent_id = 12
    PublishingApiWorker.new.perform('Edition', non_existent_id)
  end

  test "passes the update_type option to the presenter" do
    update_type = "republish"

    create(:government)
    edition = create(:published_detailed_guide)
    presenter = PublishingApiPresenters.presenter_for(edition, update_type: update_type)
    requests = [
      stub_publishing_api_put_content(presenter.content_id, presenter.content),
      stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, update_type: nil, locale: "en")
    ]

    PublishingApiWorker.new.perform(edition.class.name, edition.id, update_type)

    assert_all_requested requests
  end

  test "allows the locale to be overridden" do
    disable_publishes_to_publishing_api do
      organisation = create(:organisation)
      presenter = PublishingApiPresenters.presenter_for(organisation)

      requests = I18n.with_locale(:es) do
        organisation.name = "Spanish name"
        organisation.save!

        [
          stub_publishing_api_put_content(presenter.content_id, presenter.content),
          stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
          stub_publishing_api_publish(presenter.content_id, locale: "es", update_type: nil)
        ]
      end

      PublishingApiWorker.new.perform(organisation.class.name, organisation.id, nil, 'es')

      assert_all_requested requests
    end
  end

  test "adds any additional metadata" do
    update_type = "republish"
    extra_metadata = { foo: 'bar' }

    create(:government)
    edition = create(:published_detailed_guide)
    presenter = PublishingApiPresenters.presenter_for(edition, update_type: update_type)
    expected_content = presenter.content
    expected_content[:details][:metadata] = extra_metadata
    requests = [
      stub_publishing_api_put_content(presenter.content_id, expected_content),
      stub_publishing_api_patch_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, update_type: nil, locale: "en")
    ]

    PublishingApiWorker.new.perform(edition.class.name, edition.id, update_type, I18n.default_locale.to_s, extra_metadata)

    assert_all_requested requests
  end

  test "only raises >= 500 errors" do
    organisation = create(:organisation)

    stub_any_publishing_api_put_content.and_raise(GdsApi::HTTPServerError.new(500))

    assert_raises(GdsApi::HTTPServerError) do
      PublishingApiWorker.new.perform(organisation.class.name, organisation.id, nil, 'en')
    end
  end

  test "reports or ignores < 500 errors" do
    organisation = create(:organisation)
    error = GdsApi::HTTPClientError.new(400)

    stub_any_publishing_api_put_content.and_raise(error)

    GovukError.expects(:notify)
      .with(error, extra: { explanation: "The error code indicates that retrying this request will not help. This job is being aborted and will not be retried." })
    PublishingApiWorker.new.perform(organisation.class.name, organisation.id, nil, 'en')
  end
end
