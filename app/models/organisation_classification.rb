class OrganisationClassification < ApplicationRecord
  belongs_to :organisation
  belongs_to :classification

  belongs_to :topical_event, foreign_key: :classification_id
end
