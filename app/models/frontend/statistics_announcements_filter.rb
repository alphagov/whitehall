class Frontend::StatisticsAnnouncementsFilter < FormObject
  named "StatisticsAnnouncementsFilter"
  attr_accessor :keywords
  attr_reader :from_date, :to_date

  RESULTS_PER_PAGE = 40

  def filter_type
    "release announcement"
  end

  def page
    @page || 1
  end

  def page=(page_number)
    if page_number.to_i.positive?
      @page = page_number.to_i
    end
  end

  def to_date=(date)
    date = Chronic.parse(date, guess: :end, endian_precedence: :little) if date.is_a? String
    @to_date = if date.present?
                 (date - 1.seconds).to_date
               end
  end

  def from_date=(date)
    date = Chronic.parse(date, guess: :begin, endian_precedence: :little) if date.is_a? String
    @from_date = if date.present?
                   date.to_date
                 end
  end

  def organisations=(organisations)
    @organisations = Organisation.where(slug: Array(organisations))
  end

  def organisations
    Array(@organisations)
  end

  def organisation_slugs
    organisations.map(&:slug)
  end

  def topic_ids
    topics.map(&:content_id)
  end

  def topics=(ids)
    @topics = Taxonomy::TopicTaxonomy.new.ordered_taxons.select do |taxon|
      ids.include?(taxon.content_id)
    end
  end

  def topics
    Array(@topics)
  end

  def valid_filter_params
    params = {}
    params[:keywords]      = keywords           if keywords.present?
    params[:to_date]       = to_date            if to_date.present?
    params[:from_date]     = from_date          if from_date.present?
    params[:organisations] = organisation_slugs if organisations.present?
    params[:part_of_taxonomy_tree] = topic_ids if topics.present?
    params
  end

  def results
    @results ||= get_results
  end

  def result_count
    results.total
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

  def get_results
    results = provider.search(valid_filter_params.merge(page: page, per_page: RESULTS_PER_PAGE))
    if should_include_cancellations_within_preceding_month?
      prepend_results_to(results, get_cancelled_announcements_within_preceding_month)
    else
      results
    end
  end

  def should_include_cancellations_within_preceding_month?
    page == 1 && from_date.nil?
  end

  def get_cancelled_announcements_within_preceding_month
    provider.search(valid_filter_params.merge(page: page,
                                              per_page: RESULTS_PER_PAGE,
                                              statistics_announcement_state: 'cancelled',
                                              from_date: 1.month.ago.to_date,
                                              to_date: Time.zone.now.to_date))
  end

  def prepend_results_to(result_set, prepended_set)
    CollectionPage.new(prepended_set.concat(result_set), page: 1,
                                                         per_page: RESULTS_PER_PAGE,
                                                         total: result_set.total + prepended_set.total)
  end

  def provider
    Frontend::StatisticsAnnouncementProvider
  end
end
