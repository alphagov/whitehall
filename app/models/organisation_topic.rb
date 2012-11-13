class OrganisationTopic < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :topic

  default_scope order: "ordering ASC"
end