Whitehall.edition_services.tap do |coordinator|
  # publishing API
  coordinator.subscribe do |event, edition, options|
    ServiceListeners::PublishingApiPusher
      .new(edition)
      .push(event: event, options: options)
  end

  coordinator.subscribe do |_event, edition, _options|
    edition.attachables.flat_map(&:attachments).each do |attachment|
      ServiceListeners::AttachmentDraftStatusUpdater
        .new(attachment.attachment_data)
        .update!
      ServiceListeners::AttachmentRedirectUrlUpdater
        .new(attachment.attachment_data)
        .update!
    end
    Attachment.where(attachable_id: edition.id).find_each do |attachment|
      next unless attachment.attachment_data
      AttachmentData.where(replaced_by_id: attachment.attachment_data.id).find_each do |attachment_data|
        ServiceListeners::AttachmentReplacementIdUpdater
          .new(attachment_data)
          .update!
      end
    end
  end

  coordinator.subscribe(/^(force_publish|publish)$/) do |_event, edition, options|
    edition.attachables.flat_map(&:attachments).each do |attachment|
      ServiceListeners::AttachmentLinkHeaderUpdater
        .new(attachment.attachment_data)
        .update!
    end
  end

  coordinator.subscribe('update_draft') do |_event, edition, _options|
    edition.attachables.flat_map(&:attachments).each do |attachment|
      ServiceListeners::AttachmentAccessLimitedUpdater
        .new(attachment.attachment_data)
        .update!
    end
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
