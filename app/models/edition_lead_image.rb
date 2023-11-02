class EditionLeadImage < ApplicationRecord
  belongs_to :edition
  belongs_to :image

  accepts_nested_attributes_for :edition
end
