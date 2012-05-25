class EditionOrganisation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :organisation
end