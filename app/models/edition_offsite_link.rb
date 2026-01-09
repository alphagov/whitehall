class EditionOffsiteLink < ApplicationRecord
  belongs_to :edition
  belongs_to :offsite_link, inverse_of: :edition_offsite_links
end
