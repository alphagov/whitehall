class WorldwideOffice < ActiveRecord::Base
  has_one :contact, as: :contactable, dependent: :destroy
  belongs_to :worldwide_organisation
  has_many :worldwide_office_worldwide_services, dependent: :destroy
  has_many :services, through: :worldwide_office_worldwide_services, source: :worldwide_service

  validates :worldwide_organisation, :contact, :worldwide_office_type_id, presence: true

  accepts_nested_attributes_for :contact

  def worldwide_office_type
    WorldwideOfficeType.find_by_id(worldwide_office_type_id)
  end

  def worldwide_office_type=(worldwide_office_type)
    self.worldwide_office_type_id = worldwide_office_type && worldwide_office_type.id
  end

end
