class OrganisationMainstreamLink < ActiveRecord::Base
  belongs_to :organisation
  validates :url, :title, presence: true
  validates :url, format: URI::regexp(%w(http https))
end
