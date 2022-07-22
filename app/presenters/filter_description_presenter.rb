class FilterDescriptionPresenter
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper

  attr_reader :filter, :base_url, :date_prefix_text

  def initialize(filter, base_url, opts = {})
    @filter = filter
    @base_url = base_url
    @date_prefix_text = opts[:date_prefix_text] || "published"
  end

  def render
    [
      count_fragment,
      keywords_fragment,
      topics_fragment,
      organisations_fragment,
      date_fragment,
    ].compact.join(" ").html_safe
  end

private

  def count_fragment
    [
      tag.span(number_with_delimiter(filter.result_count), class: "count"),
      tag.strong(filter.filter_type.pluralize(filter.result_count)),
    ].join(" ")
  end

  def keywords_fragment
    if filter.respond_to?(:keywords) && filter.keywords.present?
      "containing #{tag.strong filter.keywords} #{remove_field_link(:keywords, filter.keywords, filter.keywords)}"
    end
  end

  def topics_fragment
    return if !filter.respond_to?(:topics) || filter.topics.empty?

    topics = filter.topics.map do |topic|
      "<strong>#{CGI.escapeHTML(topic.name)}</strong> #{remove_field_link(:topics, topic.base_path, topic.name)}"
    end

    "about #{topics.to_sentence}"
  end

  def organisations_fragment
    return if !filter.respond_to?(:organisations) || filter.organisations.empty?

    organisations = filter.organisations.map do |organisation|
      "<strong>#{CGI.escapeHTML(organisation.name)}</strong> #{remove_field_link(:organisations, organisation.slug, organisation.name)}"
    end

    "by #{organisations.to_sentence}"
  end

  def date_fragment
    if to_date_fragment.present? || from_date_fragment.present?
      [date_prefix_text, [from_date_fragment, to_date_fragment].compact.to_sentence].join(" ")
    end
  end

  def to_date_fragment
    @to_date_fragment ||= if filter.respond_to?(:to_date) && filter.to_date.present?
                            "<strong>before #{filter.to_date.to_fs(:long_ordinal)}</strong> #{remove_field_link(:to_date, filter.to_date, "#{date_prefix_text} before date")}"
                          end
  end

  def from_date_fragment
    @from_date_fragment ||= if filter.respond_to?(:from_date) && filter.from_date.present?
                              "<strong>after #{filter.from_date.to_fs(:long_ordinal)}</strong> #{remove_field_link(:from_date, filter.from_date, "#{date_prefix_text} after date")}"
                            end
  end

  def remove_field_link(field, value, text)
    url = "#{base_url}?#{filter.valid_filter_params.except(field).to_query}".chomp("?")
    link_to "×", url, "data-field" => field, "data-value" => value, "title" => "Remove #{text}"
  end
end
