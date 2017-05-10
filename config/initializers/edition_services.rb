Whitehall.edition_services.tap do |coordinator|
  # publishing API
  coordinator.subscribe do |event, edition, options|
    ServiceListeners::PublishingApiPusher
      .new(edition)
      .push(event: event, options: options)
  end

  coordinator.subscribe('unpublish') do |_event, edition, _options|
    # handling edition's dependency on other content
    edition.edition_dependencies.destroy_all

    # search
    ServiceListeners::SearchIndexer
      .new(edition)
      .remove!
  end

  coordinator.subscribe(/^(force_publish|publish|unwithdraw)$/) do |_event, edition, options|
    # handling edition's dependency on other content
    edition.republish_dependent_editions
    ServiceListeners::EditionDependenciesPopulator
      .new(edition)
      .populate!

    ServiceListeners::AttachmentDependencyPopulator
      .new(edition)
      .populate!

    ServiceListeners::AnnouncementClearer
      .new(edition)
      .clear!

    ServiceListeners::AuthorNotifier
      .new(edition, options[:user])
      .notify!

    Whitehall::GovUkDelivery::Notifier
      .new(edition)
      .edition_published!
  end

  coordinator.subscribe(/^(force_publish|publish|withdraw|unwithdraw)$/) do |_event, edition, _options|
    ServiceListeners::SearchIndexer
      .new(edition)
      .index!
  end

  coordinator.subscribe(/^(force_publish|publish|unwithdraw|unpublish|withdraw)$/) do |_event, edition, options|
    ServiceListeners::EditorialRemarker
      .new(edition, options[:user], options[:remark])
      .save_remark!
  end
end
