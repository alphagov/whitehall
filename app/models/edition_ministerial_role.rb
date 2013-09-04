# == Schema Information
#
# Table name: edition_ministerial_roles
#
#  id                  :integer          not null, primary key
#  edition_id          :integer
#  ministerial_role_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class EditionMinisterialRole < ActiveRecord::Base
  belongs_to :edition
  belongs_to :ministerial_role
end
