# == Schema Information
#
# Table name: organisation_classifications
#
#  id                :integer          not null, primary key
#  organisation_id   :integer          not null
#  classification_id :integer          not null
#  created_at        :datetime
#  updated_at        :datetime
#  ordering          :integer
#  lead              :boolean          default(FALSE), not null
#  lead_ordering     :integer
#

class OrganisationClassification < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :topic, foreign_key: :classification_id
  belongs_to :classification
end
