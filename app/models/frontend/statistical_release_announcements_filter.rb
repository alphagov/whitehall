class Frontend::StatisticalReleaseAnnouncementsFilter < FormObject
  named "StatisticalReleaseAnnouncementsFilter"
  attr_accessor :keywords,
                :from_date, :to_date,
                :organisations, :topics,
                :page

  RESULTS_PER_PAGE = 40

  def filter_type
    "release announcement"
  end

  def page
    @page || 1
  end

  def page=(page_number)
    if page_number.to_i > 0
      @page = page_number.to_i
    end
  end

  def to_date=(date)
    date = Chronic.parse(date, guess: :end) if date.is_a? String
    @to_date = if date.present?
      (date-1.seconds).to_date
    else
      nil
    end
  end

  def from_date=(date)
    date = Chronic.parse(date, guess: :begin) if date.is_a? String
    @from_date = if date.present?
      date.to_date
    else
      nil
    end
  end

  def organisations=(organisations)
    @organisations = organisations.map { |org|
      org.is_a?(Organisation) ? org : Organisation.find_by_slug(org)
    }.compact
  end

  def organisations
    Array(@organisations)
  end

  def organisation_slugs
    organisations.map &:slug
  end

  def topics=(topics)
    @topics = topics.map { |topic|
      topic.is_a?(Topic) ? topic : Topic.find_by_slug(topic)
    }.compact
  end

  def topics
    Array(@topics)
  end

  def topic_slugs
    topics.map &:slug
  end

  def valid_filter_params
    params = {}
    params[:keywords]      = keywords           if keywords.present?
    params[:to_date]       = to_date            if to_date.present?
    params[:from_date]     = from_date          if from_date.present?
    params[:organisations] = organisation_slugs if organisations.present?
    params[:topics]        = topic_slugs        if topics.present?
    params
  end

  def results
    @results ||= provider.search(valid_filter_params.merge(page: page, per_page: RESULTS_PER_PAGE))
  end

  def result_count
    results.count
  end

  def next_page_params
    valid_filter_params.merge(page: page + 1)
  end

  def previous_page_params
    valid_filter_params.merge(page: page - 1)
  end

  def next_page?
    results.next_page?
  end

  def prev_page?
    results.prev_page?
  end

private
  def provider
    Frontend::StatisticalReleaseAnnouncementProvider
  end
end
