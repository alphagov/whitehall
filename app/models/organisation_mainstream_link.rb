class OrganisationMainstreamLink < ActiveRecord::Base
  belongs_to :organisation
  validates :slug, :title, presence: true
end
