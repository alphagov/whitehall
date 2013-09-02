# == Schema Information
#
# Table name: worldwide_services
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  service_type_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#

class WorldwideService < ActiveRecord::Base

  validates :name, :service_type_id, presence: true
  has_many :worldwide_office_worldwide_services, dependent: :destroy
  has_many :offices, through: :worldwide_office_worldwide_services, source: :worldwide_office

  def service_type
    WorldwideServiceType.find_by_id(service_type_id)
  end

  def service_type=(service_type)
    self.service_type_id = service_type && service_type.id
  end

end
