class OrganisationMainstreamLink < ActiveRecord::Base
  belongs_to :mainstream_link
  belongs_to :organisation
end
