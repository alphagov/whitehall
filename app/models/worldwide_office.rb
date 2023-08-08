class WorldwideOffice < ApplicationRecord
  has_one :contact, as: :contactable, dependent: :destroy
  belongs_to :worldwide_organisation
  has_many :worldwide_office_worldwide_services, dependent: :destroy, inverse_of: :worldwide_office
  has_many :services, through: :worldwide_office_worldwide_services, source: :worldwide_service
  validates :worldwide_organisation, :contact, :worldwide_office_type_id, presence: true

  after_commit :republish_embassies_index_page_to_publishing_api

  delegate :default_access_and_opening_times, to: :worldwide_organisation

  accepts_nested_attributes_for :contact

  include PublishesToPublishingApi

  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :worldwide_organisation

  extend HomePageList::ContentItem
  is_stored_on_home_page_lists

  # WorldOffice quacks like a Contact
  contact_methods = Contact.column_names +
    Contact::Translation.column_names +
    %w[contact_numbers country country_code country_name has_postal_address?] -
    %w[id contactable_id contactable_type contact_id locale created_at updated_at content_id]

  delegate(*contact_methods, to: :contact, allow_nil: true)
  delegate(:non_english_translated_locales, to: :worldwide_organisation)
  delegate(:embassy_office?, to: :worldwide_office_type)

  def access_and_opening_times
    super || default_access_and_opening_times
  end

  def has_custom_access_and_opening_times?
    self[:access_and_opening_times].present?
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
    PresentPageToPublishingApi.new.publish(PublishingApi::EmbassiesIndexPresenter)
  end

  def base_path
    "/world/organisations/#{worldwide_organisation.slug}/office/#{slug}"
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
end
