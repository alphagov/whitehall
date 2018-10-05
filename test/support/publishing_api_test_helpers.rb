require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/publishing_api_v2"

module PublishingApiTestHelpers
  include GdsApi::TestHelpers::PublishingApiV2

  def stub_publishing_api_publish_intent
    stub_request(:any, %r{\A#{Plek.current.find('publishing-api')}/publish-intent\/.+})
  end

  def stub_publishing_api_registration_for(editions)
    Array(editions).each do |edition|
      presenter = PublishingApiPresenters.presenter_for(edition)
      stub_publishing_api_put_content(presenter.content_id, presenter.content)
      stub_publishing_api_patch_links(presenter.content_id, links: presenter.links)
      stub_publishing_api_publish(presenter.content_id, locale: presenter.content[:locale], update_type: nil)
    end
  end

  def expect_publishing(*editions, content_entries: {})
    editions.each do |edition|
      Services.publishing_api.expects(:put_content)
        .with(edition.content_id,
          has_entries({ publishing_app: 'whitehall' }.merge(content_entries)))
      Services.publishing_api.stubs(:patch_links)
        .with(edition.content_id, has_entries(links: anything))
      Services.publishing_api.expects(:publish)
        .with(edition.content_id, nil, locale: "en")
    end
  end

  def expect_republishing(*editions, content_entries: {})
    editions.each do |edition|
      Services.publishing_api.expects(:put_content)
        .with(edition.content_id,
          has_entries({ publishing_app: 'whitehall' }.merge(content_entries)))
      Services.publishing_api.stubs(:patch_links)
        .with(edition.content_id, has_entries(links: anything))
      Services.publishing_api.expects(:publish)
        .with(edition.content_id, nil, locale: "en")
    end
  end

  def expect_no_republishing(*editions)
    editions.each do |edition|
      Services.publishing_api.expects(:put_content)
        .with(content_id: edition.content_id).never
    end
  end

  def disable_publishes_to_publishing_api
    all_classes = ObjectSpace.each_object(Class).select { |c| c.included_modules.include?(PublishesToPublishingApi) }.reject(&:singleton_class?)
    all_classes.each do |klass|
      klass.any_instance.stubs(:publish_to_publishing_api)
      klass.any_instance.stubs(:publish_gone_to_publishing_api)
    end

    yield

    all_classes.each do |klass|
      klass.any_instance.unstub(:publish_to_publishing_api)
      klass.any_instance.unstub(:publish_gone_to_publishing_api)
    end
  end
end
