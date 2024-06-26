class MinisterialRole < Role
  include ReshuffleMode
  include UserOrderable

  has_many :editions, -> { distinct }, through: :role_appointments
  has_many :consultations, -> { where("editions.type" => "Consultation").distinct }, through: :role_appointments
  has_many :news_articles, -> { where("editions.type" => "NewsArticle").distinct }, through: :role_appointments
  has_many :speeches, through: :role_appointments

  after_save :republish_ministerial_pages_to_publishing_api

  scope :cabinet_members,
        -> { where(cabinet_member: true) }

  def published_speeches(options = {})
    speeches
      .live_edition.published
      .in_reverse_chronological_order
      .limit(options[:limit])
  end

  def published_news_articles(options = {})
    news_articles
      .live_edition.published
      .in_reverse_chronological_order
      .limit(options[:limit])
  end

  def self.cabinet
    where(cabinet_member: true).alphabetical_by_person
  end

  def self.ministerial_roles_with_current_appointments
    includes(:translations).cabinet_members.order(:seniority).joins(:current_role_appointments)
  end

  def self.also_attends_cabinet_roles
    includes(:translations).also_attends_cabinet.order(:seniority)
  end

  def self.whip_roles
    includes(:translations).whip.order(:whip_ordering)
  end

  def ministerial?
    true
  end

  def destroyable?
    super && editions.empty?
  end

private

  def default_person_name
    name
  end
end
