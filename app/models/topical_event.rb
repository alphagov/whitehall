class TopicalEvent < Classification
  searchable title: :name,
             link: :search_link,
             content: :description,
             format: 'topical_event',
             description: :description_without_markup,
             slug: :slug

  has_one :about_page

  has_many :social_media_accounts, as: :socialable, dependent: :destroy

  has_many :announcements, through: :classification_memberships
  has_many :news_articles, through: :classification_memberships
  has_many :speeches, through: :classification_memberships

  has_many :publications, through: :classification_memberships
  has_many :consultations, through: :classification_memberships

  has_many :published_announcements,
            -> { where(editions: { state: :published }) },
            through: :classification_memberships,
            class_name: "Announcement",
            source: :announcement

  has_many :published_publications,
            -> { where(editions: { state: :published }) },
            through: :classification_memberships,
            class_name: "Publication",
            source: :publication

  has_many :published_consultations,
            -> { where(editions: { state: :published }) },
            through: :classification_memberships,
            class_name: "Consultation",
            source: :consultation

  scope :active, -> { where("end_date > ?", Date.today) }
  scope :order_by_start_date, -> { order("start_date DESC") }

  validate :start_and_end_dates
  validates :start_date, presence: true, if: -> topical_event { topical_event.end_date }

  accepts_nested_attributes_for :social_media_accounts, allow_destroy: true

  alias_method :display_name, :to_s

  def archived?
    if end_date && end_date <= Date.today
      true
    else
      false
    end
  end

  def search_link
    Whitehall.url_maker.topical_event_path(slug)
  end

  private
  def start_and_end_dates
    if start_date && end_date
      if more_than_a_year(start_date, end_date)
        errors.add(:base, "cannot be longer than a year")
      end
      if start_date >= end_date
        errors.add(:end_date, "cannot be before or equal to the start_date")
      end
    end
  end

  def more_than_a_year(from_time, to_time = 0)
    to_time > from_time + 1.year + 1.day  # allow 1 day's leeway
  end
end
