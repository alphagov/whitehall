# == Schema Information
#
# Table name: sponsorships
#
#  id                        :integer          not null, primary key
#  organisation_id           :integer
#  worldwide_organisation_id :integer
#  created_at                :datetime
#  updated_at                :datetime
#

class Sponsorship < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :worldwide_organisation
end
