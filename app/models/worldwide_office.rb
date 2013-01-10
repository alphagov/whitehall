class WorldwideOffice < ActiveRecord::Base
  validates_with SafeHtmlValidator

  validates :name, :summary, :description, presence: true

  extend FriendlyId
  friendly_id
end
