class EditionRole < ActiveRecord::Base
  belongs_to :edition
  belongs_to :role
end