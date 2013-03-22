class MinisterialRole < Role
  include Searchable
  include Rails.application.routes.url_helpers

  has_many :edition_ministerial_roles
  has_many :editions, through: :edition_ministerial_roles
  has_many :speeches, through: :role_appointments
  has_many :policies, through: :edition_ministerial_roles, source: :edition, conditions: { "editions.type" => Policy }
  has_many :news_articles, through: :role_appointments, conditions: { "editions.type" => NewsArticle }, uniq: true

  def published_policies(options = {})
    policies
      .latest_published_edition
      .in_reverse_chronological_order
      .limit(options[:limit])
  end

  def published_speeches(options = {})
    speeches
      .latest_published_edition
      .in_reverse_chronological_order
      .limit(options[:limit])
  end

  def published_news_articles(options = {})
    news_articles
      .latest_published_edition
      .in_reverse_chronological_order
      .limit(options[:limit])
  end

  searchable title: :search_title,
             link: :search_link,
             content: :current_person_biography,
             format: 'minister'

  def self.cabinet
    where(cabinet_member: true).alphabetical_by_person
  end

  def ministerial?
    true
  end

  def search_title
    current_person ? "#{current_person.name} (#{to_s})" : to_s
  end

  def destroyable?
    super && editions.empty?
  end

  def seniority
    [ /^Prime Minister/,
      /^Deputy Prime Minister/,
      /^First Secretary of State/,
      // ].index { |re| name.match(re) } + 1
  end

  def search_link
    # This should be ministerial_role_path(self), but we can't use that because friendly_id's #to_param returns
    # the old value of the slug (e.g. nil for a new record) if the record is dirty, and apparently the record
    # is still marked as dirty during after_save callbacks.
    ministerial_role_path(slug)
  end
end
