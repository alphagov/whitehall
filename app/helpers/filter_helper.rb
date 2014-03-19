module FilterHelper
  def organisation_options_for_release_announcement_filter(selected_slug = nil)
    options_for_select(Organisation.with_statistical_release_announcements.alphabetical.map { |org| [org.name, org.slug] }.unshift(['All departments', nil]), Array(selected_slug))
  end

  def topic_options_for_release_announcement_filter(selected_slug = nil)
    options_for_select(Topic.with_statistical_release_announcements.alphabetical.map { |topic| [topic.name, topic.slug] }.unshift(['All topics', nil]), Array(selected_slug))
  end

  def describe_filter(filter, opts = {})
    FilterDescription.new(filter, opts).render
  end


  class FilterDescription
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::NumberHelper

    attr_reader :filter, :date_prefix_text

    def initialize(filter, opts = {})
      @filter = filter
      @date_prefix_text = opts[:date_prefix_text] || 'published'
    end

    def render
      [
        count_fragment,
        keywords_fragment,
        topics_fragment,
        organisations_fragment,
        date_fragment
      ].compact.join(' ').html_safe
    end

  private
    def count_fragment
      [
        content_tag(:span, number_with_delimiter(filter.result_count), class: 'count'),
        content_tag(:strong, filter.filter_type.pluralize(filter.result_count))
      ].join(' ')
    end

    def keywords_fragment
      if filter.respond_to?(:keywords) && filter.keywords.present?
        "containing #{content_tag :strong, filter.keywords}"
      end
    end

    def topics_fragment
      if filter.respond_to?(:topics) && filter.topics.any?
        "about " + filter.topics.map {|topic| content_tag :strong, topic.name}.to_sentence
      end
    end

    def organisations_fragment
      if filter.respond_to?(:organisations) && filter.organisations.any?
        "by " + filter.organisations.map {|organisation| content_tag :strong, organisation.name}.to_sentence
      end
    end

    def date_fragment
      if to_date_fragment.present? || from_date_fragment.present?
        [date_prefix_text, [from_date_fragment, to_date_fragment].compact.to_sentence].join(' ')
      end
    end

    def to_date_fragment
      @to_date_fragment ||= if filter.respond_to?(:to_date) && filter.to_date.present?
        content_tag :strong, "before #{filter.to_date.to_s(:long_ordinal)}"
      end
    end

    def from_date_fragment
      @from_date_fragment ||= if filter.respond_to?(:from_date) && filter.from_date.present?
        content_tag :strong, "after #{filter.from_date.to_s(:long_ordinal)}"
      end
    end
  end
end
