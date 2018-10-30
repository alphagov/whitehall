Whitehall.edition_services.tap do |coordinator|
  coordinator.subscribe do |_event, edition, _options|
    ServiceListeners::AttachmentUpdater.call(attachable: edition)
  end

  coordinator.subscribe('unpublish') do |_event, edition, _options|
    # handling edition's dependency on other content
    edition.edition_dependencies.destroy_all

    # search
    ServiceListeners::SearchIndexer
      .new(edition)
      .remove!

    # Update unpublish status
    ServiceListeners::AttachmentPresentAtUnpublishUpdater.call(attachable: edition, value: true)

    # Update attachment redirect urls
    ServiceListeners::AttachmentRedirectUrlUpdater.call(attachable: edition)
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

    # Update attachment redirect urls
    ServiceListeners::AttachmentRedirectUrlUpdater.call(attachable: edition)
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

    ServiceListeners::FeaturableOrganisationRepublisher
      .new(edition)
      .call
  end
end
