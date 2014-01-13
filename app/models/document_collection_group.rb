class DocumentCollectionGroup < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :document_collection
  has_many :memberships, class_name: 'DocumentCollectionGroupMembership',
                         order: 'document_collection_group_memberships.ordering',
                         dependent: :destroy
  has_many :documents, through: :memberships, order: 'document_collection_group_memberships.ordering'
  has_many :editions, through: :documents, order: 'document_collection_group_memberships.ordering'

  validates :heading, presence: true, uniqueness: { scope: :document_collection_id }
  validates_associated :memberships

  before_create :assign_ordering

  def set_document_ids_in_order!(document_ids)
    self.document_ids = document_ids
    self.save!
    self.memberships.each do |membership|
      membership.update_attribute(:ordering, document_ids.index(membership.document_id))
    end
  end

  def self.visible
    includes(:editions).where('editions.state = ?', 'published')
  end

  def self.default_attributes
    { heading: 'Documents' }
  end

  def published_editions
    editions.published
  end

  def latest_editions
    associations = { latest_edition: [:organisations, :translations] }
    editions = documents.includes(associations).map(&:latest_edition)
    editions.compact
  end

  def visible?
    published_editions.present?
  end

  def dup
    new_group = super
    new_group.memberships = memberships.map &:dup
    new_group
  end

  def slug
    heading.parameterize
  end

  private

  def assign_ordering
    peers = document_collection.present? ? document_collection.groups.maximum(:ordering).to_i : 0
    self.ordering = peers + 1
  end
end
