class OrganisationTopTask < ActiveRecord::Base
  belongs_to :top_task
  belongs_to :organisation
end
