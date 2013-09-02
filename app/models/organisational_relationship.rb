# == Schema Information
#
# Table name: organisational_relationships
#
#  id                     :integer          not null, primary key
#  parent_organisation_id :integer
#  child_organisation_id  :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class OrganisationalRelationship < ActiveRecord::Base
  belongs_to :parent_organisation, class_name: "Organisation"
  belongs_to :child_organisation, class_name: "Organisation"
end
