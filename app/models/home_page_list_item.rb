class HomePageListItem < ApplicationRecord
  belongs_to :home_page_list
  belongs_to :item, polymorphic: true

  validates :item, :home_page_list, presence: true
end
