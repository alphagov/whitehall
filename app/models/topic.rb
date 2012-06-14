class Topic < ActiveRecord::Base
  include ActiveRecord::Transitions
  include Searchable
  include Rails.application.routes.url_helpers

  searchable title: :name, link: :search_link, content: :description, format: 'topic'

  state_machine do
    state :current
    state :deleted

    event :delete, success: -> topic { topic.remove_from_search_index } do
      transitions from: [:current], to: :deleted, guard: :destroyable?
    end
  end

  has_many :topic_memberships
  has_many :policies, through: :topic_memberships
  has_many :featured_policies, through: :topic_memberships, class_name: "Policy", conditions: { "topic_memberships.featured" => true, "editions.state" => "published" }, source: :policy

  has_many :organisation_topics
  has_many :organisations, through: :organisation_topics

  has_many :published_policies, through: :topic_memberships, class_name: "Policy", conditions: { state: "published" }, source: :policy
  has_many :archived_policies, through: :topic_memberships, class_name: "Policy", conditions: { state: "archived" }, source: :policy

  has_many :topic_relations
  has_many :related_topics, through: :topic_relations, before_remove: -> pa, rpa {
    TopicRelation.relation_for(pa.id, rpa.id).destroy_inverse_relation
  }

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  accepts_nested_attributes_for :topic_memberships

  default_scope where('topics.state != "deleted"')

  extend FriendlyId
  friendly_id :name, use: :slugged

  EXEMPLAR_NAMES = [
    "Higher education",
    "International aid and development",
    "Law and the justice system",
    "Social care",
    "Housing",
    "Local government",
  ]

  def self.exemplars
    where(name: EXEMPLAR_NAMES)
  end

  def should_generate_new_friendly_id?
    new_record?
  end

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def self.with_published_policies
    joins(:published_policies).group(:topic_id)
  end

  def published_related_editions
    policies.published.includes(
      :published_related_editions
    ).map(&:published_related_editions).flatten.uniq
  end

  def destroyable?
    non_archived_policies = policies - archived_policies
    non_archived_policies.blank?
  end

  def feature
    update_attributes(featured: true)
  end

  def unfeature
    update_attributes(featured: false)
  end

  def search_link
    topic_path(slug)
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
