class PolicyArea < ActiveRecord::Base
  include ActiveRecord::Transitions

  state_machine do
    state :current
    state :deleted

    event :delete do
      transitions from: [:current], to: :deleted, guard: :destroyable?
    end
  end

  has_many :document_policy_areas
  has_many :policies, through: :document_policy_areas
  has_many :featured_policies, through: :document_policy_areas, class_name: "Policy", conditions: { "document_policy_areas.featured" => true }, source: :policy

  has_many :organisation_policy_areas
  has_many :organisations, through: :organisation_policy_areas

  has_many :published_policies, through: :document_policy_areas, class_name: "Policy", conditions: { state: "published" }, source: :policy
  has_many :archived_policies, through: :document_policy_areas, class_name: "Policy", conditions: { state: "archived" }, source: :policy

  has_many :policy_area_relations
  has_many :related_policy_areas, through: :policy_area_relations

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  accepts_nested_attributes_for :document_policy_areas

  default_scope where('policy_areas.state != "deleted"').order(:name)

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def self.with_published_policies
    joins(:published_policies).group(:policy_area_id)
  end

  def published_related_documents
    policies.published.includes(
      :published_documents_related_to,
      :published_documents_related_with
    ).map(&:published_related_documents).flatten.uniq
  end

  def destroyable?
    non_archived_policies = policies - archived_policies
    non_archived_policies.blank?
  end

  private

  class << self
    def randomized
      order('RAND()')
    end

    def featured
      where(featured: true)
    end
  end
end