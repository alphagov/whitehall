# This worker synchronises the state of the editions for a document with the
# publishing-api. It sends the current live Edition and the draft Edition.
#
# It is important that the requests are sent in the right order. If the
# pre_publication_edition is sent and then a publish request is sent, the wrong
# draft gets published. If the pre_publication_edition is sent and then the
# live_edition is sent and published, then the pre_publication_edition is
# lost.
#
# The design of the publishing-api means that it is impossible to republish
# something that currently has a draft without having to store the current draft
# and sending it again after republishing. This also changes the version
# numbering and would probably appear in the version history.
class PublishingApiDocumentRepublishingWorker < WorkerBase
  sidekiq_options queue: "publishing_api"

  def perform(document_id, bulk_publishing = false)
    @document = Document.find(document_id)
    @bulk_publishing = bulk_publishing

    return unless document.has_republishable_editions?

    Document.transaction do
      document.lock!

      if document.latest_unpublished_edition.present?
        refresh_latest_unpublished_edition
        refresh_pre_publication_edition if document.pre_publication_edition&.valid?
        return
      elsif document.withdrawn_edition.present?
        refresh_withdrawn_edition
        return
      end

      patch_links
      refresh_published_edition if document.published_edition.present?
      refresh_pre_publication_edition if document.pre_publication_edition&.valid?
    end
  end

private

  attr_reader :bulk_publishing, :document

  ## Edition-specific refresh wrapper methods

  def refresh_latest_unpublished_edition
    unpublish_edition
  end

  def refresh_pre_publication_edition
    Whitehall::PublishingApi.save_draft(document.pre_publication_edition, "republish", bulk_publishing:)
    handle_attachments_for(document.pre_publication_edition)
  end

  def refresh_published_edition
    refresh_live_edition
  end

  def refresh_withdrawn_edition
    refresh_live_edition
    unpublish_edition
  end

  ## Helper methods that aren't edition-specific and interact with external
  ## classes

  def handle_attachments_for(edition)
    ServiceListeners::PublishingApiAssociatedDocuments.process(edition, "republish")
  end

  def patch_links
    edition = document.published_edition || document.pre_publication_edition

    return unless edition

    Whitehall::PublishingApi.patch_links(edition, bulk_publishing:)
  end

  def refresh_live_edition
    Whitehall::PublishingApi.publish(document.live_edition, "republish", bulk_publishing:)
    handle_attachments_for(document.live_edition)
  end

  def unpublish_edition
    edition = document.latest_unpublished_edition || document.withdrawn_edition
    PublishingApiUnpublishingWorker.new.perform(edition.unpublishing.id, edition.draft?)
    handle_attachments_for(edition)
  end
end
