class PolicyArea < ActiveRecord::Base
  has_many :document_policy_areas
  has_many :documents, through: :document_policy_areas
  has_many :policies, through: :document_policy_areas, class_name: "Policy", source: :document
  has_many :featured_policies, through: :document_policy_areas, class_name: "Policy", source: :document, conditions: { "document_policy_areas.featured" => true }
  has_many :news_articles, through: :document_policy_areas, class_name: "NewsArticle", source: :document

  has_many :published_documents, through: :document_policy_areas, class_name: "Document", conditions: { state: "published" }, source: :document

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  before_destroy :prevent_destruction_if_associated

  accepts_nested_attributes_for :document_policy_areas

  default_scope order(:name)

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def self.with_published_documents
    joins(:published_documents).group(:policy_area_id)
  end

  def published_related_documents
    policies.published.includes(
      :published_documents_related_to,
      :published_documents_related_with
    ).map(&:published_related_documents).flatten.uniq
  end

  def destroyable?
    documents.blank?
  end

  private

  def prevent_destruction_if_associated
    return false unless destroyable?
  end

  class << self
    def randomized
      order('RAND()')
    end

    def featured
      where(featured: true)
    end
  end
end