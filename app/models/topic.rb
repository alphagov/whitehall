class Topic < ActiveRecord::Base
  include ActiveRecord::Transitions
  include Searchable
  include Rails.application.routes.url_helpers

  searchable title: :name,
             link: :search_link,
             content: :description,
             format: 'topic'

  state_machine do
    state :current
    state :deleted

    event :delete, success: -> topic { topic.remove_from_search_index } do
      transitions from: [:current], to: :deleted, guard: :destroyable?
    end
  end

  has_many :topic_memberships
  has_many :policies, through: :topic_memberships
  has_many :detailed_guides, through: :topic_memberships
  has_many :published_detailed_guides, through: :topic_memberships, class_name: "DetailedGuide", conditions: { "editions.state" => "published" }, source: :detailed_guide

  has_many :organisation_topics
  has_many :organisations, through: :organisation_topics

  has_many :published_policies, through: :topic_memberships, class_name: "Policy", conditions: { "editions.state" => "published" }, source: :policy
  has_many :archived_policies, through: :topic_memberships, class_name: "Policy", conditions: { state: "archived" }, source: :policy

  has_many :published_editions, through: :topic_memberships, conditions: { "editions.state" => "published" }, source: :edition

  has_many :topic_relations
  has_many :related_topics, through: :topic_relations, before_remove: -> pa, rpa {
    TopicRelation.relation_for(pa.id, rpa.id).destroy_inverse_relation
  }

  validates_with SafeHtmlValidator
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  accepts_nested_attributes_for :topic_memberships

  default_scope where(arel_table[:state].not_eq("deleted"))

  scope :with_content, where("published_edition_count <> 0")

  def self.with_related_detailed_guides
    joins(:published_detailed_guides).group(arel_table[:id])
  end

  def self.with_related_announcements
    joins(:published_policies).
      group(arel_table[:id]).
      where("EXISTS (
        SELECT * FROM edition_relations er_check
        JOIN editions announcement_check
          ON announcement_check.id=er_check.edition_id
            AND announcement_check.state='published'
        WHERE
          er_check.document_id=editions.document_id AND
          announcement_check.type in (?)
          )", Announcement.sti_names)
  end

  def self.with_related_publications
    includes(:published_policies).select { |t| t.published_policies.map(&:published_related_publication_count).sum > 0 }
  end

  def self.with_related_policies
    joins(:published_policies).group(arel_table[:id])
  end

  scope :alphabetical, order("name ASC")

  scope :randomized, order('RAND()')

  extend FriendlyId
  friendly_id :name, use: :slugged

  def update_counts
    update_attribute(:published_edition_count, published_editions.count)
  end

  def should_generate_new_friendly_id?
    new_record?
  end

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
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

  def search_link
    topic_path(slug)
  end

  def recently_changed_documents
    (policies.published + published_related_editions).sort_by(&:published_at).reverse
  end
end
