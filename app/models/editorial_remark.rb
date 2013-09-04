# == Schema Information
#
# Table name: editorial_remarks
#
#  id         :integer          not null, primary key
#  body       :text
#  edition_id :integer
#  author_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class EditorialRemark < ActiveRecord::Base
  belongs_to :edition
  belongs_to :author, class_name: "User"

  validates :edition, :body, :author, presence: true
end
