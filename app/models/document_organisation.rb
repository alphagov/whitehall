class DocumentOrganisation < ActiveRecord::Base
  belongs_to :document, foreign_key: :edition_id
  belongs_to :organisation
end