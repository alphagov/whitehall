class EditionCountry < ActiveRecord::Base
  belongs_to :edition
  belongs_to :country
end