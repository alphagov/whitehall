class DocumentOrganisation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :organisation
end