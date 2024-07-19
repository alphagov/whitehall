class WorldwideOffice < ApplicationRecord
  has_one :contact, as: :contactable, dependent: :destroy
  belongs_to :worldwide_organisation
  belongs_to :edition
  has_many :worldwide_office_worldwide_services, dependent: :destroy, inverse_of: :worldwide_office
  has_many :services, through: :worldwide_office_worldwide_services, source: :worldwide_service
  validates :worldwide_organisation, :contact, :worldwide_office_type_id, presence: true
  validate :worldwide_organisation_or_edition

  # after_commit :republish_embassies_index_page_to_publishing_api

  accepts_nested_attributes_for :contact

  include PublishesToPublishingApi

  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :worldwide_organisation

  extend HomePageList::ContentItem
  is_stored_on_home_page_lists

  contact_methods = %w[
    comments
    contact_form_url
    contact_numbers
    contact_type_id
    country
    country_code
    country_id
    country_name
    email
    has_postal_address?
    locality
    postal_code
    recipient
    region
    street_address
    title
  ]

  delegate(*contact_methods, to: :contact, allow_nil: true)
  delegate(:non_english_translated_locales, to: :worldwide_organisation)
  delegate(:embassy_office?, to: :worldwide_office_type)

  def can_publish_to_publishing_api?
    return false if edition

    super
  end

  def can_publish_gone_to_publishing_api?
    return false if edition

    super
  end

  def worldwide_organisation
    super || edition
  end

  def translatable?
    true
  end

  def worldwide_office_type
    WorldwideOfficeType.find_by_id(worldwide_office_type_id)
  end

  def worldwide_office_type=(worldwide_office_type)
    self.worldwide_office_type_id = worldwide_office_type && worldwide_office_type.id
  end

  def available_in_multiple_languages?
    false
  end

  def republish_embassies_index_page_to_publishing_api
    PresentPageToPublishingApiWorker.perform_async("PublishingApi::EmbassiesIndexPresenter")
  end

  def base_path
    "#{worldwide_organisation.base_path}/office/#{slug}"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end

  def publishing_api_presenter
    PublishingApi::WorldwideOfficePresenter
  end

private

  def worldwide_organisation_or_edition
    if worldwide_organisation_id && edition
      errors.add(:associations, "Only worldwide organisation or edition allowed")
    end
  end
end
