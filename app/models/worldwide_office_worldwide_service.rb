# == Schema Information
#
# Table name: worldwide_office_worldwide_services
#
#  id                   :integer          not null, primary key
#  worldwide_office_id  :integer          not null
#  worldwide_service_id :integer          not null
#  created_at           :datetime
#  updated_at           :datetime
#

class WorldwideOfficeWorldwideService < ActiveRecord::Base

  belongs_to :worldwide_office
  belongs_to :worldwide_service

  validates :worldwide_service, :worldwide_office, presence: true

end
