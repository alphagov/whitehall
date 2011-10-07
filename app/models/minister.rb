class Minister < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :organisation
end