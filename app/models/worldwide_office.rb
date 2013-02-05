class WorldwideOffice < ActiveRecord::Base
  has_many :worldwide_office_world_locations, dependent: :destroy
  has_many :world_locations, through: :worldwide_office_world_locations
  has_many :contacts, as: :contactable, dependent: :destroy
  has_many :social_media_accounts, as: :socialable, dependent: :destroy

  validates_with SafeHtmlValidator
  validates :name, :summary, :description, presence: true

  extend FriendlyId
  friendly_id

  def display_name
    self.name
  end
end
