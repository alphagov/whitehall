class Whitehall::DocumentFilter
  extend Forwardable
  attr_reader :documents

  delegate [:count, :current_page, :num_pages, :last_page?, :first_page?] => :documents

  def initialize(documents, params = {})
    @documents = documents
    @params = params
    filter_by_topics!
    filter_by_departments!
    filter_by_keywords!
    filter_by_date!
    paginate!
    apply_sort_direction!
  end

  def all_topics
    Topic.with_content.order(:name)
  end

  def all_topics_with(type)
    case type
    when :publication
      Topic.with_related_publications.sort_by(&:name)
    when :specialist_guide
      Topic.with_related_specialist_guides.order(:name)
    when :announcement
      Topic.with_related_announcements.order(:name)
    end
  end

  def all_organisations_with(type)
    Organisation.joins(:"published_#{type}s").group(:name).ordered_by_name_ignoring_prefix
  end

  def selected_topics
    find_by_slug(Topic, @params[:topics])
  end

  def selected_organisations
    find_by_slug(Organisation, @params[:departments])
  end

  def keywords
    if @params[:keywords].present?
      @params[:keywords].strip.split(/\s+/)
    else
      []
    end
  end

  def direction
    @params[:direction]
  end

  def date
    Date.parse(@params[:date]) if @params[:date].present?
  end

private

  def find_by_slug(klass, slugs)
    @selected ||= {}
    @selected[klass] ||= if slugs.present? && !slugs.include?("all")
      klass.where(slug: slugs)
    else
      []
    end
  end

  def filter_by_topics!
    @documents = @documents.in_topic(selected_topics) if selected_topics.any?
  end

  def filter_by_departments!
    @documents = @documents.in_organisation(selected_organisations) if selected_organisations.any?
  end

  def filter_by_keywords!
    @documents = @documents.with_summary_containing(*keywords) if keywords.any?
  end

  def filter_by_date!
    if date.present? && direction.present?
      case direction
      when "before"
        @documents = @documents.published_before(date)
      when "after"
        @documents = @documents.published_after(date)
      end
    end
  end

  def paginate!
    if @params[:page].present?
      @documents = @documents.page(@params[:page]).per(20)
    end
  end

  def apply_sort_direction!
    if direction.present?
      case direction
      when "before"
        @documents = @documents.in_reverse_chronological_order
      when "after"
        @documents = @documents.in_chronological_order
      when "alphabetical"
        @documents = @documents.alphabetical
      end
    end
  end
end
