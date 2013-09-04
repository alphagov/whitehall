# == Schema Information
#
# Table name: home_page_list_items
#
#  id                :integer          not null, primary key
#  home_page_list_id :integer          not null
#  item_id           :integer          not null
#  item_type         :string(255)      not null
#  ordering          :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class HomePageListItem < ActiveRecord::Base
  belongs_to :home_page_list
  belongs_to :item, polymorphic: true

  validates :item, :home_page_list, presence: true
end
