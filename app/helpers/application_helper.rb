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

  def page_class(css_class)
    content_for(:page_class, css_class)
  end

  def atom_discovery_link_tag(url = nil, title = nil)
    # This helper is used to get *and* set data for
    # rendering an atom feed URL.
    # rubocop:disable Rails/HelperInstanceVariable
    @atom_discovery_link_url = url if url.present?
    @atom_discovery_link_title = title if title.present?
    auto_discovery_link_tag(:atom, @atom_discovery_link_url || atom_feed_url(format: :atom), title: @atom_discovery_link_title || "Recent updates")
    # rubocop:enable Rails/HelperInstanceVariable
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
    html_class = options[:class]
    link_to name, attachment.url(options), class: html_class
  end

  def text_for_role_appointment(appointment)
    if appointment.current?
      appointment.role.name
    else
      "#{appointment.role.name} (#{l(appointment.started_at.to_date)} to #{l(appointment.ended_at.to_date)})"
    end
  end

  def publication_type_options
    [
      ["", [""]],
      ["Common types",
       PublicationType.primary.map do |publication_type|
         [publication_type.singular_name, publication_type.id]
       end],
      ["Less common types",
       PublicationType.less_common.map do |publication_type|
         [publication_type.singular_name, publication_type.id]
       end],
      ["Use discouraged",
       PublicationType.use_discouraged.map do |publication_type|
         [publication_type.singular_name, publication_type.id]
       end],
    ]
  end

  def worldwide_office_type_options
    WorldwideOfficeType.by_grouping.map do |grouping, types|
      [
        grouping,
        types.map { |t| [t.name, t.id] },
      ]
    end
  end

  def news_article_type_options
    [
      ["", [""]],
      ["Common types",
       NewsArticleType.all.map do |type|
         [type.singular_name, type.id]
       end],
    ]
  end

  def speech_type_options
    [
      ["", [""]],
      ["Common types",
       SpeechType.primary.map do |type|
         [type.singular_name, type.id]
       end],
    ]
  end

  def role_type_options
    RoleTypePresenter.options
  end

  def render_list_of_roles(roles, class_name = "ministerial_roles")
    raise ArgumentError, "please supply the content of the list item" unless block_given?

    tag.ul(class: class_name) do
      roles.each do |role|
        li = content_tag_for(:li, role) {
          yield(RolePresenter.new(role, self)).html_safe
        }.html_safe
        concat li
      end
    end
  end

  def render_list_of_ministerial_roles(ministerial_roles, &block)
    render_list_of_roles(ministerial_roles, &block)
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
    CorporateInformationPageType.all.map { |c| [c.title(organisation), c.id] }
  end

  def is_external?(href)
    if (host = Addressable::URI.parse(href).host)
      Whitehall.public_host != host
    end
  end

  def right_to_left?
    Locale.new(I18n.locale).rtl?
  end

  def content_tag_if_not_empty(name, options = {}, &block)
    content = capture(&block)
    if content.present? && content.strip
      content_tag(name, content, **options)
    else
      ""
    end
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
end
