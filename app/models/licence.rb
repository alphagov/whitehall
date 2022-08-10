class Licence < ApplicationRecord
  serialize :activities, Array
  has_and_belongs_to_many :sectors
end
