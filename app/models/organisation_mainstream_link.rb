# == Schema Information
#
# Table name: organisation_mainstream_links
#
#  id                 :integer          not null, primary key
#  organisation_id    :integer
#  mainstream_link_id :integer
#

class OrganisationMainstreamLink < ActiveRecord::Base
  belongs_to :mainstream_link
  belongs_to :organisation
end
