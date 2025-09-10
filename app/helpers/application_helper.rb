require "record_tag_helper/helper"

module ApplicationHelper
  include ActionView::Helpers::RecordTagHelper

  def page_title(*title_parts)
    # This helper may be called multiple times on the
    # same page, with or without the necessary arguments
    # to construct the title (e.g. on a nested form).
    # rubocop:disable Rails/HelperInstanceVariable
    if title_parts.any?
      title_parts.push("Admin") if params[:controller].match?(/^admin\//)
      title_parts.push("GOV.UK")
      @page_title = title_parts.reject(&:blank?).join(" - ")
    else
      @page_title
    end
    # rubocop:enable Rails/HelperInstanceVariable
  end

  def page_start_index(page, options = {})
    return 0 unless page

    per_page = options[:per_page] || Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE
    (page.to_i - 1) * per_page
  end

  def page_class(css_class)
    content_for(:page_class, css_class)
  end

  def format_in_paragraphs(string, options = {})
    safe_join(
      String(string)
        .split(/(?:\r?\n){2}/)
        .map { |paragraph| tag.p(paragraph, class: options[:class]) },
    )
  end

  def format_with_html_line_breaks(string)
    ERB::Util.html_escape(string || "").strip.gsub(/(?:\r?\n)/, "<br/>").html_safe
  end

  def link_to_attachment(attachment, options = {})
    return unless attachment

    name = attachment.name_for_link
    html_class = options.delete(:class)

    return link_to name, attachment.url(options), class: html_class if !attachment.file? || attachment.attachment_data.asset_uploaded?

    tag.span(name)
  end

  def link_to_attachment_data(attachment_data)
    return link_to attachment_data.filename, attachment_data.url, class: "govuk-link" if attachment_data.asset_uploaded?

    tag.span(attachment_data.filename)
  end

  def worldwide_office_type_options
    WorldwideOfficeType.by_grouping.map do |types|
      types
    end
  end

  def role_type_options
    RoleTypePresenter.options
  end

  def render_datetime_microformat(object, method, &block)
    tag.time(class: method, datetime: object.send(method).iso8601, &block)
  end

  def absolute_time(time, options = {})
    return unless time

    tag.time(
      l(time, format: :long_ordinal),
      class: [options[:class], "datetime"].compact.join(" "),
      datetime: time.iso8601,
    )
  end

  def absolute_date(time, options = {})
    return unless time

    tag.time(
      l(time.to_date, format: :long_ordinal),
      class: [options[:class], "date"].compact.join(" "),
      datetime: time.iso8601,
      lang: "en",
    )
  end

  def linked_author(author, link_options = {})
    if author
      link_to(author.name, admin_author_path(author), link_options)
    else
      "-"
    end
  end

  def corporate_information_page_types(organisation)
    organisation.corporate_information_page_types.map { |c| [c.title(organisation), c.id] }
  end

  def is_external?(href)
    if (host = Addressable::URI.parse(href).host)
      Whitehall.public_host != host
    end
  end

  def right_to_left?
    Locale.new(I18n.locale).rtl?
  end

  def joined_list(elements)
    separator = if elements.any? { |word| word.include?(",") }
                  "; "
                else
                  ", "
                end
    elements.join(separator)
  end

  def render_govspeak(content)
    render "govuk_publishing_components/components/govspeak" do
      raw(Govspeak::Document.new(content, sanitize: true).to_html)
    end
  end

  def diff_html(version1, version2)
    Diffy::Diff.new(version1, version2, allow_empty_diff: false).to_s(:html).html_safe
  end

  def add_indefinite_article(noun)
    indefinite_article = starts_with_vowel?(noun) ? "an" : "a"
    "#{indefinite_article} #{noun}"
  end

  def starts_with_vowel?(word_or_phrase)
    "aeiou".include?(word_or_phrase.downcase[0])
  end

  def get_content_id(edition)
    return if edition.nil?

    return unless edition.respond_to?("content_id")

    edition.content_id
  end
end
