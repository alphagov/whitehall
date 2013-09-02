# == Schema Information
#
# Table name: contacts
#
#  id               :integer          not null, primary key
#  latitude         :decimal(15, 10)
#  longitude        :decimal(15, 10)
#  email            :string(255)
#  contact_form_url :string(255)
#  contactable_id   :integer
#  contactable_type :string(255)
#  title            :string(255)
#  comments         :text
#  recipient        :string(255)
#  street_address   :text
#  locality         :string(255)
#  region           :string(255)
#  postal_code      :string(255)
#  country_id       :integer
#  contact_type_id  :integer          not null
#

class Contact < ActiveRecord::Base
  belongs_to :contactable, polymorphic: true
  has_many :contact_numbers, dependent: :destroy
  belongs_to :country, class_name: "WorldLocation",
    foreign_key: :country_id,
    conditions: { "world_locations.world_location_type_id" => WorldLocationType::WorldLocation.id }

  validates :title, :contact_type, presence: true
  validates :contact_form_url, uri: true, allow_blank: true
  validates :street_address, :country_id, presence: true, if: -> r { r.has_postal_address? }
  accepts_nested_attributes_for :contact_numbers, allow_destroy: true, reject_if: :all_blank

  extend HomePageList::ContentItem
  is_stored_on_home_page_lists

  def contactable_name
    if contactable.is_a? WorldwideOffice
      contactable.worldwide_organisation.name
    else
      if contactable.acronym.present?
        contactable.acronym
      else
        contactable.name
      end
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
  def media?
    contact_type == ContactType::Media
  end
  def general?
    contact_type == ContactType::General
  end
end
