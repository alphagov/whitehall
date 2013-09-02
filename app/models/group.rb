# == Schema Information
#
# Table name: groups
#
#  id              :integer          not null, primary key
#  organisation_id :integer
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  slug            :string(255)
#  description     :text
#

class Group < ActiveRecord::Base
  belongs_to :organisation
  has_many :group_memberships
  has_many :members, through: :group_memberships, source: :person

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

  validates_with Validator

  extend FriendlyId
  friendly_id

  before_destroy :prevent_destruction_unless_destroyable

  default_scope order(:name)

  def destroyable?
    members.empty?
  end

  private

  def prevent_destruction_unless_destroyable
    return false unless destroyable?
  end
end
