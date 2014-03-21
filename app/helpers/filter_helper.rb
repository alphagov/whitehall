# encoding: utf-8

module FilterHelper
  def organisation_options_for_statistics_announcement_filter(selected_slug = nil)
    options_for_select(Organisation.with_statistics_announcements.alphabetical.map { |org| [org.name, org.slug] }.unshift(['All departments', nil]), Array(selected_slug))
  end

  def topic_options_for_statistics_announcement_filter(selected_slug = nil)
    options_for_select(Topic.with_statistics_announcements.alphabetical.map { |topic| [topic.name, topic.slug] }.unshift(['All topics', nil]), Array(selected_slug))
  end

  def describe_filter(filter, base_url, opts = {})
    FilterDescription.new(filter, base_url, opts).render
  end


  class FilterDescription
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::NumberHelper

    attr_reader :filter, :base_url, :date_prefix_text

    def initialize(filter, base_url, opts = {})
      @filter = filter
      @base_url = base_url
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
        "containing #{content_tag :strong, filter.keywords} #{remove_field_link(:keywords, filter.keywords, filter.keywords)}"
      end
    end

    def topics_fragment
      if filter.respond_to?(:topics) && filter.topics.any?
        "about " + filter.topics.map {|topic|
          "<strong>#{topic.name}</strong> #{remove_field_link(:topics, topic.slug, topic.name)}"
        }.to_sentence
      end
    end

    def organisations_fragment
      if filter.respond_to?(:organisations) && filter.organisations.any?
        "by " + filter.organisations.map {|organisation|
          "<strong>#{organisation.name}</strong> #{remove_field_link(:organisations, organisation.slug, organisation.name)}"
        }.to_sentence
      end
    end

    def date_fragment
      if to_date_fragment.present? || from_date_fragment.present?
        [date_prefix_text, [from_date_fragment, to_date_fragment].compact.to_sentence].join(' ')
      end
    end

    def to_date_fragment
      @to_date_fragment ||= if filter.respond_to?(:to_date) && filter.to_date.present?
        "<strong>before #{filter.to_date.to_s(:long_ordinal)}</strong> #{remove_field_link(:to_date, filter.to_date, "#{date_prefix_text} before date")}"
      end
    end

    def from_date_fragment
      @from_date_fragment ||= if filter.respond_to?(:from_date) && filter.from_date.present?
        "<strong>after #{filter.from_date.to_s(:long_ordinal)}</strong> #{remove_field_link(:from_date, filter.from_date, "#{date_prefix_text} after date")}"
      end
    end

    def remove_field_link(field, value, text)
      url = (base_url + '?' + filter.valid_filter_params.except(field).to_query).chomp('?')
      link_to "×", url, "data-field" => field, "data-value" => value, "title" => "Remove #{text}"
    end
  end
end
