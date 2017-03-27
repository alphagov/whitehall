class PublishingApiPublicationsWorker
  extend Forwardable
  include Sidekiq::Worker

  def perform(edition_id, event)
    self.publication =
      Publication.unscoped.find(edition_id)

    send(event) if respond_to?(event) && publication_effects_about_pages?
  end

  def publish
    return unless about_us_pages.present?

    about_us_pages
      .map(&:document_id)
      .each(&PublishingApiDocumentRepublishingWorker.method(:perform_async))
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

  attr_accessor :publication
  def_delegator :publication, :organisations
  def_delegator :publication, :publication_type

  def about_us_pages
    return unless organisations.present?

    organisations
      .map(&:about_us)
      .compact
  end

  def publication_effects_about_pages?
    [
      PublicationType::CorporateReport,
      PublicationType::FoiRelease,
      PublicationType::TransparencyData,
    ].include?(publication_type)
  end
end
