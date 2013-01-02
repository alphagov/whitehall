class TopicalEvent < Classification
  searchable title: :name,
             link: :search_link,
             content: :description,
             format: 'topical_event',
             description: :description

  has_many :social_media_accounts, as: :socialable, dependent: :destroy

  has_many :announcments, through: :classification_memberships
  has_many :news_articles, through: :classification_memberships
  has_many :speeches, through: :classification_memberships

  has_many :published_announcements,
            through: :classification_memberships,
            class_name: "Announcement",
            conditions: { "editions.state" => "published" },
            source: :announcement

  has_many :published_publications,
            through: :classification_memberships,
            class_name: "Publication",
            conditions: { "editions.state" => "published" },
            source: :publication

  has_many :classification_featurings, foreign_key: :classification_id, order: "classification_featurings.ordering asc"

  accepts_nested_attributes_for :social_media_accounts, allow_destroy: true
  accepts_nested_attributes_for :classification_featurings

  alias :display_name :to_s

  def featured?(edition)
    return false unless edition.persisted?
    featuring_of(edition).present?
  end

  def featuring_of(edition)
    classification_featurings.where(edition_id: edition.id).first
  end

  def feature(featuring_params)
    classification_featurings.create({ordering: next_ordering}.merge(featuring_params))
  end

  def next_ordering
    last = classification_featurings.order("ordering desc").limit(1).last
    last ? last.ordering + 1 : 1
  end

  def recently_changed_documents
    (published_announcements + published_publications).sort_by(&:timestamp_for_sorting).reverse
  end
end