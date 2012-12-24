class EditionCountry < ActiveRecord::Base
  belongs_to :edition
  belongs_to :world_location, foreign_key: :country_id
end