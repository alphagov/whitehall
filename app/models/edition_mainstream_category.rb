# == Schema Information
#
# Table name: edition_mainstream_categories
#
#  id                     :integer          not null, primary key
#  edition_id             :integer
#  mainstream_category_id :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class EditionMainstreamCategory < ActiveRecord::Base
  belongs_to :edition
  belongs_to :mainstream_category
end
