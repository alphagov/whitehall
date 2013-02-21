class WorldwideService < ActiveRecord::Base

  validates :name, :service_type_id, presence: true

  def service_type
    WorldwideServiceType.find_by_id(service_type_id)
  end

  def service_type=(service_type)
    self.service_type_id = service_type && service_type.id
  end

end