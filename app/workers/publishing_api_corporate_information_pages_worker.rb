class PublishingApiCorporateInformationPagesWorker
  extend Forwardable
  include Sidekiq::Worker

  def perform(edition_id, event)
    self.corporate_information_page =
      CorporateInformationPage.unscoped.find(edition_id)

    send(event) if respond_to?(event)
  end

  def publish
    return unless about_us_page.present?

    PublishingApiDocumentRepublishingWorker.perform_async(
      about_us_page.document_id,
    )

    organisation.save! if organisation
  end

  alias :delete :publish
  alias :force_publish :publish
  alias :republish :publish
  alias :unpublish :publish
  alias :unwithdraw :publish
  alias :update_draft :publish
  alias :update_draft_translation :publish
  alias :withdraw :publish

private

  attr_accessor :corporate_information_page
  def_delegator :corporate_information_page, :organisation

  def about_us_page
    return unless organisation.present?

    organisation.about_us
  end
end
