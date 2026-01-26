class OffsiteLinkParent < ApplicationRecord
  belongs_to :parent, polymorphic: true
  belongs_to :offsite_link
end
