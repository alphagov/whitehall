class Activity < ApplicationRecord
  has_and_belongs_to_many :sectors
end
