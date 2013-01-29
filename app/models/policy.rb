class Policy < Edition
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Topics
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::SupportingPages
  include Edition::WorldLocations
  include Edition::AlternativeFormatProvider

  has_many :edition_relations, through: :document
  has_many :related_editions, through: :edition_relations, source: :edition
  has_many :published_related_editions, through: :edition_relations, source: :edition, conditions: {editions: {state: 'published'}}
  has_many :published_related_publications, through: :edition_relations, source: :edition, conditions: {editions: {type: Publicationesque.sti_names, state: 'published'}}
  has_many :published_related_announcements, through: :edition_relations, source: :edition, conditions: {document: {editions: {type: Announcement.sti_names, state: 'published'}}}
  has_many :case_studies, through: :edition_relations, source: :edition, conditions: {editions: {type: 'CaseStudy', state: 'published'}}


  has_many :edition_policy_groups, foreign_key: :edition_id
  has_many :policy_teams, through: :edition_policy_groups, class_name: 'PolicyTeam', source: :policy_group
  has_many :policy_advisory_groups, through: :edition_policy_groups, class_name: 'PolicyAdvisoryGroup', source: :policy_group

  def self.having_announcements
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

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      edition.related_editions = @edition.related_editions
    end
  end

  add_trait Trait

  after_destroy :remove_edition_relations

  def search_index
    super.merge("topics" => topics.map(&:id))
  end

  def alternative_format_provider_required?
    true
  end

  def update_published_related_publication_count
    update_attribute(:published_related_publication_count, published_related_publications.count)
  end

  def policy_team
    policy_teams.first
  end

  private

  def remove_edition_relations
    edition_relations.each(&:destroy)
  end
end
