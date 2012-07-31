class Whitehall::DocumentFilter
  attr_reader :selected_topics, :selected_organisations, :keywords, :date, :direction

  def initialize(documents)
    @documents = documents
    @selected_topics = []
    @selected_organisations = []
    @keywords = []
    @direction = "before"
  end

  def all_topics
    Topic.with_content.order(:name)
  end

  def all_organisations(type)
    Organisation.joins(:"published_#{type}s").group(:name).ordered_by_name_ignoring_prefix
  end

  def by_topics(topic_slugs)
    if topic_slugs.present? && !topic_slugs.include?("all")
      @selected_topics = Topic.where(slug: topic_slugs)
    end
    self
  end

  def by_organisations(organisation_slugs)
    if organisation_slugs.present? && !organisation_slugs.include?("all")
      @selected_organisations = Organisation.where(slug: organisation_slugs)
    end
    self
  end

  def by_keywords(keywords)
    if keywords.present?
      @keywords = keywords.split(/\s+/)
    end
    self
  end

  def by_date(date, direction)
    if date.present?
      @date = Date.parse(date)
    end

    if direction.present?
      @direction = direction
      if @date.present?
        case @direction
        when "before"
          @documents = @documents.published_before(@date)
        when "after"
          @documents = @documents.published_after(@date)
        end
      end
    end
    self
  end

  def paginate(page)
    @page = page
    self
  end

  def documents
    @documents = @documents.in_topic(@selected_topics) if @selected_topics.any?
    @documents = @documents.in_organisation(@selected_organisations) if @selected_organisations.any?
    @documents = @documents.with_content_containing(*@keywords) if @keywords.any?

    @documents = if "after" == @direction
      @documents.in_chronological_order
    else
      @documents.in_reverse_chronological_order
    end

    if @page
      @documents.page(@page).per(20)
    else
      @documents
    end
  end
end