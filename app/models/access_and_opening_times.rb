# == Schema Information
#
# Table name: access_and_opening_times
#
#  id              :integer          not null, primary key
#  body            :text
#  accessible_type :string(255)
#  accessible_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class AccessAndOpeningTimes < ActiveRecord::Base
  belongs_to :accessible, polymorphic: true

  validates_with SafeHtmlValidator
  validates :body, presence: true
end
