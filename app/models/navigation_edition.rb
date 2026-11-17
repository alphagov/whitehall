class NavigationEdition < ApplicationRecord
  belongs_to :navigation
  belongs_to :edition, class_name: "StandardEdition"
end
