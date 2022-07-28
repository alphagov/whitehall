# This worker synchronises the state of the editions for a document with the
# publishing-api. It sends the current published Edition and the draft Edition.
#
# It is important that the requests are sent in the right order. If the
# pre_publication_edition is sent and then a publish request is sent, the wrong
# draft gets published. If the pre_publication_edition is sent and then the
# published_edition is sent and published, then the pre_publication_edition is
# lost.
#
# The design of the publishing-api means that it is impossible to republish
# something that currently has a draft without having to store the current draft
# and sending it again after republishing. This also changes the version
# numbering and would probably appear in the version history.
class PublishingApiDocumentRepublishingWorker < WorkerBase
  include LockedDocumentConcern

  attr_reader :published_edition, :pre_publication_edition

  sidekiq_options queue: "publishing_api"

  def perform(document_id, bulk_publishing = false)
    @bulk_publishing = bulk_publishing
    document = Document.find(document_id)
    check_if_locked_document(document: document)

    # this the latest edition in a visible state ie: withdrawn, published
    @published_edition = document.live_edition
    # this is the latest edition in a non visible state - draft, scheduled
    # unpublished editions (other than withdrawn) will be in draft state with
    # an associated unpublishing
    @pre_publication_edition = document.pre_publication_edition

    return unless the_document_has_an_edition_to_check?

    Document.transaction do
      # Lock the document to prevent other
      # PublishingApiDocumentRepublishingWorker jobs from sending
      # requests to the Publishing API at the same time, as this is
      # unsafe, and the state in the Publishing API might end up being
      # incorrect.
      document.lock!

      if the_document_has_been_unpublished?
        send_draft_and_unpublish
      elsif the_document_has_been_withdrawn?
        send_published_and_withdraw
      elsif there_is_only_a_draft?
        patch_links
        send_draft_edition
      elsif there_is_only_a_published_edition?
        patch_links
        send_published_edition
      elsif there_is_a_newer_draft?
        patch_links
        send_published_edition
        send_draft_edition
      else
        error_message = <<-ERROR
          Document id: #{document.id} has an unrecognised state for republishing.
          the_document_has_been_unpublished? = #{the_document_has_been_unpublished?}
          the_document_has_been_withdrawn? = #{the_document_has_been_withdrawn?}
          there_is_only_a_draft? = #{there_is_only_a_draft?}
          there_is_only_a_published_edition? = #{there_is_only_a_published_edition?}
          there_is_a_newer_draft? = #{there_is_a_newer_draft?}
          published_edition.id = #{published_edition.try(:id)}
          pre_publication_edition.id = #{pre_publication_edition.try(:id)}
          published_edition.unpublishing = #{published_edition.try(:unpublishing)}
          pre_publication_edition.unpublishing = #{pre_publication_edition.try(:unpublishing)}
        ERROR
        raise error_message
      end
    end
  end

private

  def the_document_has_an_edition_to_check?
    # there are documents in the Whitehall DB with only superseded editions
    # this is mostly legacy data
    pre_publication_edition || published_edition
  end

  def the_document_has_been_unpublished?
    pre_publication_edition && pre_publication_edition.unpublishing
  end

  def the_document_has_been_withdrawn?
    published_edition && published_edition.unpublishing
  end

  def there_is_only_a_draft?
    pre_publication_edition && published_edition.nil?
  end

  def there_is_only_a_published_edition?
    published_edition && pre_publication_edition.nil?
  end

  def there_is_a_newer_draft?
    pre_publication_edition && published_edition
  end

  def send_draft_and_unpublish
    send_draft_edition
    send_unpublish(pre_publication_edition)
    handle_attachments_for(pre_publication_edition)
  end

  def send_draft_edition
    Whitehall::PublishingApi.save_draft(
      pre_publication_edition,
      "republish",
      bulk_publishing: @bulk_publishing,
    )
    handle_attachments_for(pre_publication_edition)
  end

  def send_published_and_withdraw
    send_published_edition
    send_unpublish(published_edition)
    handle_attachments_for(published_edition)
  end

  def send_published_edition
    Whitehall::PublishingApi.publish(
      published_edition,
      "republish",
      bulk_publishing: @bulk_publishing,
    )
    handle_attachments_for(published_edition)
  end

  def patch_links
    Whitehall::PublishingApi.patch_links(
      published_edition || pre_publication_edition,
      bulk_publishing: @bulk_publishing,
    )
  end

  def send_unpublish(edition)
    PublishingApiUnpublishingWorker.new.perform(edition.unpublishing.id, edition.draft?)
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
