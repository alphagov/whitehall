class Rank < ActiveRecord::Base
  validates :name, presence: true
end