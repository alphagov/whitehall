class EditionOrganisation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :organisation

  validates :edition, :organisation, presence: true
end
