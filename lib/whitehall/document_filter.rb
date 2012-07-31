class Whitehall::DocumentFilter
  attr_reader :selected_topics, :selected_organisations, :documents, :keywords, :date, :direction

  def initialize(documents)
    @documents = documents
  end

  def all_topics
    Topic.with_content.order(:name)
  end

  def all_organisations
    Organisation.joins(:published_publications).group(:name).ordered_by_name_ignoring_prefix
  end

  def by_topics(topic_slugs)
    @selected_topics = []
    if topic_slugs.present? && !topic_slugs.include?("all")
      @selected_topics = Topic.where(slug: topic_slugs)
      @documents = @documents.in_topic(@selected_topics)
    end
  end

  def by_organisations(organisation_slugs)
    @selected_organisations = []
    if organisation_slugs.present? && !organisation_slugs.include?("all")
      @selected_organisations = Organisation.where(slug: organisation_slugs)
      @documents = @documents.in_organisation(@selected_organisations)
    end
  end

  def by_keywords(keywords)
    if keywords.present?
      @keywords = keywords.split(/\s+/)
      @documents = @documents.with_content_containing(*@keywords)
    end
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
    else
      @direction = "before"
    end

    if "after" == @direction
      @documents = @documents.in_chronological_order
    else
      @documents = @documents.in_reverse_chronological_order
    end
  end

  def paginate(page)
    @documents = @documents.page(page).per(20)
  end
end