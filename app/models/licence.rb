class Licence < ApplicationRecord
  has_and_belongs_to_many :sectors
  has_one :activity
end
