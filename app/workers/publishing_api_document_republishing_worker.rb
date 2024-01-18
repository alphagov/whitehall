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
  attr_reader :live_edition, :pre_publication_edition, :latest_unpublished_edition

  sidekiq_options queue: "publishing_api"

  def perform(document_id, bulk_publishing = false)
    @bulk_publishing = bulk_publishing
    document = Document.find(document_id)

    # this the latest edition in a visible state ie: withdrawn, published
    @live_edition = document.live_edition

    @pre_publication_edition = document.pre_publication_edition
    @latest_unpublished_edition = document.editions.unpublished.last

    return unless the_document_has_non_superseded_editions_to_republish?

    Document.transaction do
      document.lock!

      if the_document_has_been_unpublished?
        send_unpublish(latest_unpublished_edition)
        send_draft_edition if pre_publication_edition.present?
      elsif the_document_has_been_withdrawn?
        send_published_and_withdraw
      elsif there_is_only_a_draft?
        patch_links
        send_draft_edition
      elsif there_is_only_a_live_edition?
        patch_links
        send_live_edition
      elsif there_is_a_newer_draft?
        patch_links
        send_live_edition
        send_draft_edition
      end
    end
  end

private

  def the_document_has_non_superseded_editions_to_republish?
    pre_publication_edition || live_edition || latest_unpublished_edition
  end

  def the_document_has_been_unpublished?
    @latest_unpublished_edition.present?
  end

  def the_document_has_been_withdrawn?
    live_edition && live_edition.unpublishing
  end

  def there_is_only_a_draft?
    pre_publication_edition && live_edition.nil?
  end

  def there_is_only_a_live_edition?
    live_edition && pre_publication_edition.nil?
  end

  def there_is_a_newer_draft?
    pre_publication_edition && live_edition
  end

  def send_draft_edition
    return unless pre_publication_edition.valid?

    Whitehall::PublishingApi.save_draft(
      pre_publication_edition,
      "republish",
      bulk_publishing: @bulk_publishing,
    )
    handle_attachments_for(pre_publication_edition)
  end

  def send_published_and_withdraw
    send_live_edition
    send_unpublish(live_edition)
  end

  def send_live_edition
    Whitehall::PublishingApi.publish(
      live_edition,
      "republish",
      bulk_publishing: @bulk_publishing,
    )
    handle_attachments_for(live_edition)
  end

  def patch_links
    Whitehall::PublishingApi.patch_links(
      live_edition || pre_publication_edition,
      bulk_publishing: @bulk_publishing,
    )
  end

  def send_unpublish(edition)
    PublishingApiUnpublishingWorker.new.perform(edition.unpublishing.id, edition.draft?)
    handle_attachments_for(edition)
  end

  def locales_for(edition)
    Whitehall::PublishingApi.locales_for(edition).each do |locale|
      yield locale.to_s
    end
  end

  def handle_attachments_for(edition)
    ServiceListeners::PublishingApiHtmlAttachments.process(
      edition,
      "republish",
    )
  end
end
