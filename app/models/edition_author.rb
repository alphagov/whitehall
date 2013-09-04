# == Schema Information
#
# Table name: edition_authors
#
#  id         :integer          not null, primary key
#  edition_id :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class EditionAuthor < ActiveRecord::Base
  belongs_to :edition
  belongs_to :user
end
