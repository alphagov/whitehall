class Group < ActiveRecord::Base
  belongs_to :organisation
  has_many :group_memberships
  has_many :members, through: :group_memberships, source: :person

  accepts_nested_attributes_for :group_memberships, allow_destroy: true

  validates :name, :organisation, presence: true

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
