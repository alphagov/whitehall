class WorldwideOffice < ActiveRecord::Base
  validates_with SafeHtmlValidator

  extend FriendlyId
  friendly_id
end
