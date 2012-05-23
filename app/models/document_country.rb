class DocumentCountry < ActiveRecord::Base
  belongs_to :edition
  belongs_to :country
end