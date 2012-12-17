class OrganisationTopic < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :topic
end