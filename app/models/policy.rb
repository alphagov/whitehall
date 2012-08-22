class Policy < Edition
  include Edition::NationalApplicability
  include Edition::Topics
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::SupportingPages
  include Edition::Countries
  include Edition::AlternativeFormatProvider

  has_many :edition_relations, through: :document
  has_many :related_editions, through: :edition_relations, source: :edition
  has_many :published_related_editions, through: :edition_relations, source: :edition, conditions: {editions: {state: 'published'}}
  has_many :published_related_publications, through: :edition_relations, source: :edition, conditions: {editions: {type: 'Publication', state: 'published'}}
  has_many :case_studies, through: :edition_relations, source: :edition, conditions: {editions: {type: 'CaseStudy', state: 'published'}}

  belongs_to :policy_team

  validates :summary, presence: true

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      edition.related_editions = @edition.related_editions
    end
  end

  add_trait Trait

  after_destroy :remove_edition_relations

  def sluggable_title
    title
  end

  def alternative_format_provider_required?
    true
  end
  
  def has_summary?
    true
  end

  def update_published_related_publication_count
    update_attribute(:published_related_publication_count, published_related_publications.count)
  end

  private

  def remove_edition_relations
    edition_relations.each(&:destroy)
  end
end
