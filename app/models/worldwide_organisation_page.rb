class WorldwideOrganisationPage < ApplicationRecord
  include HasContentId
  include Attachable
  include HasCorporateInformationPageType
  include TranslatableModel

  belongs_to :edition

  validates :body, presence: true
  validates :edition, presence: true
  validates :corporate_information_page_type_id,
            presence: true,
            exclusion: { in: [CorporateInformationPageType::AboutUs.id], message: "Type cannot be `About us`" }
  validates :summary, presence: true
  validate :unique_worldwide_organisation_and_page_type, on: :create, if: :edition
  validate :parent_edition_has_locales, if: :edition

  after_commit :republish_worldwide_organisation_draft
  after_destroy :discard_draft

  translates :title, :summary, :body

  delegate :alternative_format_contact_email, to: :sponsoring_organisation, allow_nil: true
  def sponsoring_organisation
    edition.lead_organisations.first
  end

  def title(_locale = :en)
    corporate_information_page_type.title(edition)
  end

  def default_locale_title
    corporate_information_page_type.default_locale_title(edition)
  end

  def missing_translations
    super & edition.non_english_translated_locales
  end

  def publicly_visible?
    true
  end

  def access_limited?
    false
  end

  def publishing_api_presenter
    PublishingApi::WorldwideOrganisationPagePresenter
  end

  def base_path
    "#{edition.base_path}/about/#{slug}"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end

private

  def republish_worldwide_organisation_draft
    Whitehall.edition_services.draft_updater(edition).perform! if edition.present?
  end

  def discard_draft
    PublishingApiDiscardDraftWorker.perform_async(content_id, I18n.default_locale.to_s)
  end

  def unique_worldwide_organisation_and_page_type
    current_page_types = edition.pages.map(&:corporate_information_page_type_id).flatten
    duplicate_page = current_page_types.include?(corporate_information_page_type_id)

    if duplicate_page
      errors.add(:base, "Another '#{display_type_key.humanize}' page already exists for this worldwide organisation")
    end
  end

  def parent_edition_has_locales
    non_existent_translations = non_english_translated_locales - edition.non_english_translated_locales

    unless non_existent_translations.empty?
      errors.add(:base, "Translations '#{non_existent_translations.map(&:code).join(', ')}' do not exist for this worldwide organisation")
    end
  end
end
