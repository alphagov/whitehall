# @abstract
class Classification < ActiveRecord::Base
  include Searchable
  include SimpleWorkflow

  searchable title: :name,
             link: :search_link,
             content: :description,
             description: :description_without_markup,
             format: 'topic',
             slug: :slug

  has_many :classification_memberships
  has_many :editions, through: :classification_memberships
  has_many :policies, through: :classification_memberships, :order => 'classification_memberships.ordering ASC'
  has_many :detailed_guides, through: :classification_memberships
  has_many :published_detailed_guides,
            through: :classification_memberships,
            class_name: "DetailedGuide",
            conditions: { "editions.state" => "published" },
            source: :detailed_guide

  has_many :organisation_classifications
  has_many :organisations, through: :organisation_classifications

  has_many :published_policies,
            through: :classification_memberships,
            class_name: "Policy",
            conditions: { "editions.state" => "published" },
            source: :policy,
            order: 'classification_memberships.ordering ASC'
  has_many :archived_policies,
            through: :classification_memberships,
            class_name: "Policy",
            conditions: { state: "archived" },
            source: :policy

  has_many :published_editions,
            through: :classification_memberships,
            conditions: { "editions.state" => "published" },
            source: :edition
  has_many :scheduled_editions,
            through: :classification_memberships,
            conditions: { "editions.state" => "scheduled" },
            source: :edition

  has_many :classification_relations
  has_many :related_classifications,
            through: :classification_relations,
            before_remove: -> pa, rpa {
              ClassificationRelation.relation_for(pa.id, rpa.id).destroy_inverse_relation
            }

  validates_with SafeHtmlValidator
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  accepts_nested_attributes_for :classification_memberships
  accepts_nested_attributes_for :organisation_classifications

  scope :with_content, where("published_edition_count <> 0")
  scope :with_policies, where("published_policies_count <> 0")

  mount_uploader :logo, ImageUploader, mount_on: :carrierwave_image

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
  friendly_id

  def lead_organisations
    organisations.where(organisation_classifications: {lead: true}).reorder("organisation_classifications.lead_ordering")
  end

  def lead_organisation_classifications
    organisation_classifications.where(lead: true).order("organisation_classifications.lead_ordering")
  end

  def update_counts
    update_column(:published_edition_count, published_editions.count)
    update_column(:published_policies_count, published_policies.count)
  end

  def destroyable?
    non_archived_policies = policies - archived_policies
    non_archived_policies.blank?
  end

  def search_link
    Whitehall.url_maker.topic_path(slug)
  end

  def latest(limit = 3)
    editions.published.without_editions_of_type(WorldLocationNewsArticle).in_reverse_chronological_order.includes(:translations).limit(limit)
  end

  def description_without_markup
    Govspeak::Document.new(description).to_text
  end

  def to_s
    name
  end

  private
    def logo_changed?
      changes["carrierwave_image"].present?
    end
end