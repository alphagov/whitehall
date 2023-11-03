class DocumentCollectionGroup < ApplicationRecord
  belongs_to :document_collection, inverse_of: :groups, touch: true
  has_many :memberships,
           -> { order("document_collection_group_memberships.ordering") },
           class_name: "DocumentCollectionGroupMembership",
           inverse_of: :document_collection_group,
           dependent: :destroy
  has_many :documents,
           -> { order("document_collection_group_memberships.ordering") },
           through: :memberships
  has_many :non_whitehall_links,
           -> { order("document_collection_group_memberships.ordering") },
           class_name: "DocumentCollectionNonWhitehallLink",
           through: :memberships
  has_many :editions,
           -> { order("document_collection_group_memberships.ordering") },
           through: :documents

  scope :live,
        lambda {
          left_joins(:non_whitehall_links, documents: :editions)
            .where("editions.state = 'published' OR document_collection_non_whitehall_links.id IS NOT NULL")
        }

  validates :heading, presence: true, uniqueness: { scope: :document_collection_id, case_sensitive: false } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates_associated :memberships

  before_create :assign_ordering

  def set_membership_ids_in_order!(membership_ids)
    self.membership_ids = membership_ids
    save!
    memberships.each do |membership|
      membership.update(ordering: membership_ids.index(membership.id))
    end
  end

  def self.default_attributes
    { heading: "Collection" }
  end

  def editable_members
    memberships.filter do |member|
      member.document&.latest_edition || member.non_whitehall_link
    end
  end

  def dup
    new_group = super
    new_group.memberships = memberships.map(&:dup)
    new_group
  end

  def slug
    heading.parameterize
  end

  def content_ids
    memberships.map(&:content_id)
  end

  def published_editions
    editions.published
  end

private

  def assign_ordering
    peers = document_collection.present? ? document_collection.groups.maximum(:ordering).to_i : 0
    self.ordering = peers + 1
  end
end
