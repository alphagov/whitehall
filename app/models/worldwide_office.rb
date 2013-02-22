class WorldwideOffice < ActiveRecord::Base
  has_one :contact, as: :contactable, dependent: :destroy
  belongs_to :worldwide_organisation
  has_many :worldwide_office_worldwide_services, dependent: :destroy
  has_many :services, through: :worldwide_office_worldwide_services, source: :worldwide_service

  validates :worldwide_organisation, :contact, presence: true

  accepts_nested_attributes_for :contact

  def available_in_multiple_languages?
    translated_locales.length > 1
  end
end
