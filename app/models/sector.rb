class Sector < ApplicationRecord
  belongs_to :parent_sector, class_name: :Sector, optional: true
  has_many :sectors, foreign_key: :parent_sector_id
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :licences
end
