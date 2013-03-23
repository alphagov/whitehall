require 'validators/url_validator.rb'

class Contact < ActiveRecord::Base
  belongs_to :contactable, polymorphic: true
  has_many :contact_numbers, dependent: :destroy
  belongs_to :country, class_name: "WorldLocation",
    foreign_key: :country_id,
    conditions: { "world_locations.world_location_type_id" => WorldLocationType::WorldLocation.id }

  validates :title, presence: true
  validates :contact_form_url, url: true, allow_blank: true
  validates :street_address, :country_id, presence: true, if: -> r { r.has_postal_address? }
  accepts_nested_attributes_for :contact_numbers, allow_destroy: true, reject_if: :all_blank

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
end
