class PublishingApiUnpublishingWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'publishing_api'

  def perform(unpublishing_id, allow_draft = false)
    unpublishing = Unpublishing.includes(:edition).find(unpublishing_id)
    edition = unpublishing.edition
    content_id = Document.where(id: edition.document_id).pluck(:content_id).first

    edition.available_locales.each do |locale|
      case unpublishing.unpublishing_reason_id
      when UnpublishingReason::PUBLISHED_IN_ERROR_ID
        if unpublishing.redirect?
          PublishingApiRedirectWorker.new.perform(
            content_id,
            unpublishing.alternative_path,
            locale,
            allow_draft
          )
        else
          PublishingApiGoneWorker.new.perform(
            content_id,
            unpublishing.alternative_path,
            unpublishing.explanation,
            locale,
            allow_draft
          )
        end
      when UnpublishingReason::CONSOLIDATED_ID
        PublishingApiRedirectWorker.new.perform(
          content_id,
          unpublishing.alternative_path,
          locale,
          allow_draft
        )
      when UnpublishingReason::WITHDRAWN_ID
        PublishingApiWithdrawalWorker.new.perform(
          content_id,
          unpublishing.explanation,
          locale,
          allow_draft
        )
      end
    end

    Whitehall::PublishingApi.save_draft_async(edition)
  end
end
