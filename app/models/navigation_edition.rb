class NavigationEdition < ApplicationRecord
  belongs_to :navigation
  belongs_to :edition, class_name: "StandardEdition"
  has_many :navigation_items, dependent: :destroy
end
