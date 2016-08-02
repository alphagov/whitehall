class Group < ActiveRecord::Base
  belongs_to :organisation
  has_many :group_memberships
  has_many :members, -> { order 'group_memberships.id' }, through: :group_memberships, source: :person

  accepts_nested_attributes_for :group_memberships, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, uniqueness: { scope: :organisation_id }
  validates :organisation_id, presence: true

  class Validator < ActiveModel::Validator
    def validate(record)
      if record && record.group_memberships.map(&:person) != record.group_memberships.map(&:person).uniq
        record.errors[:base] = "The same person has been added more than once."
      end
    end
  end

  def update_memberships_and_attributes(group_params, person_ids)
    # This methods is intended to allow us to preserve the ordering of
    # associated members. By destroying all group_memberships and then
    # rebuilding them we ensure that the ascending membership IDs reflect the
    # order of members in the edit form.
    begin
      Group.transaction do
        self.group_memberships.destroy_all

        person_ids.each do |person_id|
          self.group_memberships.build(person_id: person_id)
        end

        self.assign_attributes(group_params)
        save!
      end
    rescue
      false
    end
  end

  validates_with Validator

  extend FriendlyId
  friendly_id

  before_destroy :prevent_destruction_unless_destroyable

  default_scope -> { order(:name) }

  def destroyable?
    members.empty?
  end

  private

  def prevent_destruction_unless_destroyable
    return false unless destroyable?
  end
end
