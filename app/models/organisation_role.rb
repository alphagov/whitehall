# == Schema Information
#
# Table name: organisation_roles
#
#  id              :integer          not null, primary key
#  organisation_id :integer
#  role_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  ordering        :integer
#

class OrganisationRole < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :role

  validates :organisation_id, :role_id, presence: true
end
