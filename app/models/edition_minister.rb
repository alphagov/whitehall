class EditionMinister < ActiveRecord::Base
  belongs_to :edition
  belongs_to :minister
end