class FeaturedServicesAndGuidance < ActiveRecord::Base
  self.table_name = :featured_services_and_guidance

  def self.default_set_size
    10
  end

  include FeaturedLink
end
