class CorporateInformationPage < Edition
  include ::Attachable
  include Searchable
  include HasCorporateInformationPageType

  after_commit :republish_organisation_to_publishing_api
  after_commit :republish_about_page_to_publishing_api, unless: :about_page?
  after_save :reindex_organisation_in_search_index, if: :about_page?

  has_one :edition_organisation, foreign_key: :edition_id, dependent: :destroy
  has_one :organisation, -> { includes(:translations) }, through: :edition_organisation, autosave: false

  validate :unique_organisation_and_page_type, on: :create, if: :organisation

  add_trait do
    def process_associations_before_save(new_edition)
      new_edition.organisation = @edition.organisation
    end
  end
  delegate :alternative_format_contact_email, :acronym, to: :organisation

  validates :corporate_information_page_type_id, presence: true

  scope :with_organisation_govuk_status, ->(status) { joins(:organisation).where(organisations: { govuk_status: status }) }
  scope :accessible_documents_policy, -> { where(corporate_information_page_type_id: CorporateInformationPageType::AccessibleDocumentsPolicy.id) }

  def republish_organisation_to_publishing_api
    return if organisation.blank?

    Whitehall::PublishingApi.republish_async(organisation)
  end

  def republish_about_page_to_publishing_api
    about_us = if state == "draft"
                 organisation&.about_us_for(state: "draft")
               else
                 organisation&.about_us
               end
    return unless about_us

    PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
      "bulk_republishing",
      about_us.document_id,
      true,
    )
  end

  def reindex_organisation_in_search_index
    organisation.update_in_search_index
  end

  def body_required?
    !about_page?
  end

  def search_title
    title_prefix_organisation_name
  end

  def search_index
    super.merge("organisations" => [organisation.slug])
  end

  def self.search_only
    live_govuk_status = super.with_organisation_govuk_status("live")

    accessible_other_govuk_status = super
      .accessible_documents_policy
      .with_organisation_govuk_status(%w[joining exempt transitioning])

    accessible_devolved_govuk_status = super
      .accessible_documents_policy
      .with_organisation_govuk_status("closed")
      .where(organisations: { govuk_closed_status: "devolved" })

    live_govuk_status
      .or(accessible_other_govuk_status)
      .or(accessible_devolved_govuk_status)
  end

  def title_required?
    false
  end

  def skip_organisation_validation?
    true
  end

  def translatable?
    !non_english_edition?
  end

  def organisations
    [organisation]
  end

  def sorted_organisations
    organisations
  end

  def title_prefix_organisation_name
    [organisation.name, title].join(" \u2013 ")
  end

  def title(_locale = :en)
    corporate_information_page_type.title(organisation)
  end

  def title_lang
    corporate_information_page_type.title_lang(organisation)
  end

  def summary_required?
    false
  end

  def about_page?
    corporate_information_page_type.try(:slug) == "about"
  end

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end

  def previously_published
    false
  end

  def alternative_format_provider
    organisation
  end

  def alternative_format_provider_required?
    attachments.any? { |a| a.is_a?(FileAttachment) }
  end

  def base_path
    return if organisation.blank?

    if about_page?
      "#{organisation.base_path}/about"
    else
      "#{organisation.base_path}/about/#{slug}"
    end
  end

  def publishing_api_presenter
    PublishingApi::CorporateInformationPagePresenter
  end

private

  def string_for_slug
    nil
  end

  def unique_organisation_and_page_type
    duplicate_scope = CorporateInformationPage
      .joins(:edition_organisation)
      .where("edition_organisations.organisation_id = ?", organisation.id)
      .where(corporate_information_page_type_id:)
      .where("state not like 'superseded'")
    if document_id
      duplicate_scope = duplicate_scope.where("document_id <> ?", document_id)
    end
    if duplicate_scope.exists?
      errors.add(:base, "Another '#{display_type_key.humanize}' page was already published for this organisation")
    end
  end
end
