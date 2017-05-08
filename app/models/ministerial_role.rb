class MinisterialRole < Role
  include Searchable
  include PublishesToPublishingApi

  has_many :editions, -> { uniq }, through: :role_appointments
  has_many :consultations, -> { where("editions.type" => "Consultation").uniq }, through: :role_appointments
  has_many :news_articles, -> { where("editions.type" => "NewsArticle").uniq }, through: :role_appointments
  has_many :speeches, through: :role_appointments

  def published_policies
    if current_person
      current_person.published_policies
    else
      []
    end
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

  searchable title: :to_s,
             link: :search_link,
             content: :current_person_biography,
             description: :search_description,
             format: 'minister'

  def self.cabinet
    where(cabinet_member: true).alphabetical_by_person
  end

  def ministerial?
    true
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

  def search_description
    if current_person
      "Current role holder: #{current_person.name}."
    else
      ""
    end
  end

private
  def default_person_name
    name
  end
end
