class WorldwideOffice < ActiveRecord::Base
  include Whitehall::Models::SocialMedia
  include Whitehall::Models::Contacts

  has_many :worldwide_office_world_locations, dependent: :destroy
  has_many :world_locations, through: :worldwide_office_world_locations

  validates_with SafeHtmlValidator
  validates :name, :summary, :description, presence: true

  extend FriendlyId
  friendly_id

  def display_name
    self.name
  end
end
