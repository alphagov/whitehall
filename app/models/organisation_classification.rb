class OrganisationClassification < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :topic, foreign_key: :classification_id
  belongs_to :classification
end