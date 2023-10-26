class EditionLeadImage < ApplicationRecord
  belongs_to :edition
  belongs_to :image
end
