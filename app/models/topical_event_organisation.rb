class TopicalEventOrganisation < ApplicationRecord
  belongs_to :organisation
  belongs_to :topical_event
end
