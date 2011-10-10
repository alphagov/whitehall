class Role < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :person

  validates :name, presence: true, uniqueness: true
end