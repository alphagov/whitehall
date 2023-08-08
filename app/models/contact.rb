class Contact < ApplicationRecord
  include Dependable
  include PublishesToPublishingApi

  belongs_to :contactable, polymorphic: true
  has_many   :contact_numbers, dependent: :destroy
  belongs_to :country,
             -> { where("world_locations.world_location_type" => "world_location") },
             class_name: "WorldLocation",
             foreign_key: :country_id

  validates :title, :contact_type, presence: true
  validates :contact_form_url, uri: true, allow_blank: true
  validates :street_address, :country_id, presence: true, if: ->(r) { r.has_postal_address? }
  accepts_nested_attributes_for :contact_numbers, allow_destroy: true, reject_if: :all_blank

  after_update :republish_dependent_editions
  after_update :republish_dependent_policy_groups

  after_create :republish_organisation_to_publishing_api
  after_destroy :republish_organisation_to_publishing_api

  after_commit :republish_embassies_index_page_to_publishing_api, :republish_worldwide_office_to_publishing_api

  include TranslatableModel
  translates :title,
             :comments,
             :recipient,
             :street_address,
             :locality,
             :region,
             :email,
             :contact_form_url

  extend HomePageList::ContentItem
  is_stored_on_home_page_lists

  def republish_organisation_to_publishing_api
    Whitehall::PublishingApi.republish_async(contactable) if contactable.is_a?(Organisation)
  end

  def republish_worldwide_office_to_publishing_api
    Whitehall::PublishingApi.republish_async(contactable) if contactable.is_a?(WorldwideOffice)
  end

  def contactable_name
    if contactable.is_a? WorldwideOffice
      contactable.worldwide_organisation.name
    elsif contactable.acronym.present?
      contactable.acronym
    else
      contactable.name
    end
  end

  def has_postal_address?
    recipient.present? || street_address.present? || locality.present? ||
      region.present? || postal_code.present? || country_id.present?
  end

  def country_code
    country.try(:iso2)
  end

  def country_name
    country.try(:name)
  end

  def contact_type
    ContactType.find_by_id(contact_type_id)
  end

  def contact_type=(new_contact_type)
    self.contact_type_id = new_contact_type && new_contact_type.id
  end

  def foi?
    contact_type == ContactType::FOI
  end

  def missing_translations
    super & contactable.non_english_translated_locales
  end

  def republish_embassies_index_page_to_publishing_api
    PresentPageToPublishingApi.new.publish(PublishingApi::EmbassiesIndexPresenter)
  end

  def publishing_api_presenter
    PublishingApi::ContactPresenter
  end
end
