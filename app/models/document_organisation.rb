class DocumentOrganisation < ActiveRecord::Base
  belongs_to :document
  belongs_to :organisation
end