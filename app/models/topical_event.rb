class TopicalEvent < Classification
  searchable title: :name,
             link: :search_link,
             content: :description,
             format: 'topical_event',
             description: :description

  has_many :social_media_accounts, as: :socialable, dependent: :destroy

  has_many :announcements, through: :classification_memberships
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

  has_many :classification_featurings,
            foreign_key: :classification_id,
            order: "classification_featurings.ordering asc",
            include: :edition,
            conditions: { editions: { state: "published" } }

  has_many :featured_editions,
            through: :classification_featurings,
            source: :edition,
            order: "classification_featurings.ordering ASC"

  scope :active, -> { where("end_date > ?", Date.today) }

  validate :start_and_end_dates
  validates :start_date, presence: true, if: -> topical_event { topical_event.end_date }

  accepts_nested_attributes_for :social_media_accounts, allow_destroy: true
  accepts_nested_attributes_for :classification_featurings

  alias_method :display_name, :to_s

  def featured?(edition)
    return false unless edition.persisted?
    featuring_of(edition).present?
  end

  def archived?
    if end_date && end_date <= Date.today
      true
    else
      false
    end
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
    (published_announcements + published_publications).sort_by(&:public_timestamp).reverse
  end

  def search_link
    topical_event_path(slug)
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

  #adapted from action_view/helpers/date_helper.rb
  def more_than_a_year(from_time, to_time = 0)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance = (to_time.to_f - from_time.to_f).abs
    distance_in_minutes = (distance / 60.0).round
    distance_in_seconds = distance.round

    fyear = from_time.year
    fyear += 1 if from_time.month >= 3
    tyear = to_time.year
    tyear -= 1 if to_time.month < 3
    leap_years = (fyear > tyear) ? 0 : (fyear..tyear).count{|x| Date.leap?(x)}
    minute_offset_for_leap_year = leap_years * 1440
    # Discount the leap year days when calculating year distance.
    # e.g. if there are 20 leap year days between 2 dates having the same day
    # and month then the based on 365 days calculation
    # the distance in years will come out to over 80 years when in written
    # english it would read better as about 80 years.
    minutes_with_offset         = distance_in_minutes - minute_offset_for_leap_year
    remainder                   = (minutes_with_offset % 525600)
    distance_in_years           = (minutes_with_offset / 525600)

    if distance_in_years > 1
      true
    elsif distance_in_years == 1 && remainder > 1440 #Allow one day overrun
      true
    else
      false
    end
  end
end
