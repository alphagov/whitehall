class OrganisationRole < ActiveRecord::Base
  include MinisterialRole::MinisterialRoleReindexingConcern

  belongs_to :organisation, inverse_of: :organisation_roles
  belongs_to :role, inverse_of: :organisation_roles

  validates :organisation, :role, presence: true

  before_create :set_ordering, if: -> { ordering.blank? }

private

  def set_ordering
    self.ordering = next_ordering
  end

  def next_ordering
    max = organisation.organisation_roles.maximum(:ordering)
    max ? max + 1 : 0
  end
end
