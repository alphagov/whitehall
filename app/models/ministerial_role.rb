class MinisterialRole < Role
  include Searchable

  has_many :edition_ministerial_roles
  has_many :editions, through: :edition_ministerial_roles
  has_many :speeches, through: :role_appointments
  has_many :policies, through: :edition_ministerial_roles, source: :edition, conditions: { "editions.type" => Policy }
  has_many :news_articles, through: :role_appointments, conditions: { "editions.type" => NewsArticle }, uniq: true

  after_update :touch_role_appointments

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

  def search_link
    # This should be ministerial_role_path(self), but we can't use that because friendly_id's #to_param returns
    # the old value of the slug (e.g. nil for a new record) if the record is dirty, and apparently the record
    # is still marked as dirty during after_save callbacks.
    Whitehall.url_maker.ministerial_role_path(slug)
  end

private
  def default_person_name
    name
  end

  # Whenever a ministerial role is updated, we want touch the updated_at
  # timestamps of any associated role appointments so that the cache digest for
  # the taggable_ministerial_role_appointments_container gets invalidated.
  def touch_role_appointments
    role_appointments.update_all updated_at: Time.zone.now
  end
end
