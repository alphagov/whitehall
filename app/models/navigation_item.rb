class NavigationItem < ApplicationRecord
  belongs_to :navigation_edition
  belongs_to :child_document, class_name: "Document"

  def child_edition
    child_document.latest_edition
  end
end
