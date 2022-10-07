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

  def format_in_paragraphs(string)
    safe_join(
      String(string)
        .split(/(?:\r?\n){2}/)
        .map { |paragraph| tag.p(paragraph) },
    )
  end

  def format_with_html_line_breaks(string)
    ERB::Util.html_escape(string || "").strip.gsub(/(?:\r?\n)/, "<br/>").html_safe
  end

  def link_to_attachment(attachment, options = {})
    return unless attachment

    name = attachment.name_for_link
    name = truncate(name) if options[:truncate]
    link_to name, attachment.url(options)
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

  def full_width_tabs(tab_data)
    tag.nav(class: "activity-navigation") do
      tag.ul do
        tab_data.map { |tab|
          tag.li do
            if tab[:current_when]
              link_to tab[:label], tab[:link_to], class: ("current" if tab[:current_when])
            else
              link_to_with_current(tab[:label], tab[:link_to])
            end
          end
        }.join.html_safe
      end
    end
  end

  def link_to_with_current(name, path, options = {})
    options = options.dup
    path_matcher = options.delete(:current_path) || Regexp.new("^#{Regexp.escape(path)}$")
    css_classes = [options[:class], current_link_class(path_matcher)].join(" ").strip
    options[:class] = css_classes if css_classes.present?

    link_to name, path, options
  end

  def current_link_class(path_matcher)
    request.path.match?(path_matcher) ? "current" : ""
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

  def main_navigation_link_to(name, path, html_options = {}, &block)
    classes = (html_options[:class] || "").split
    if current_main_navigation_path(params) == path
      classes << "active"
    end
    link_to(name, path, html_options.merge(class: classes.join(" ")), &block)
  end

  def current_main_navigation_path(parameters)
    case parameters[:controller]
    when "announcements", "news_articles", "speeches", "fatality_notices", "operational_fields"
      announcements_path
    when "consultations", "consultation_responses"
      publications_path(publication_filter_option: "consultations")
    when "corporate_information_pages"
      if parameters.key?(:worldwide_organisation_id)
        world_locations_path
      else
        organisations_path
      end
    when "histories", "past_foreign_secretaries", "historic_appointments"
      how_government_works_path
    when "home"
      case parameters[:action]
      when "home"
        root_path
      when "get_involved"
        get_involved_path
      else
        how_government_works_path
      end
    when "latest"
      if parameters[:departments]
        organisations_path
      elsif parameters[:world_locations]
        world_locations_path
      else
        latest_path
      end
    when "ministerial_roles"
      ministerial_roles_path
    when "organisations", "groups", "email_signup_information"
      if parameters[:courts_only]
        courts_path
      else
        organisations_path
      end
    when "publications", "statistical_data_sets"
      if parameters[:publication_filter_option] == "consultations"
        publications_path(publication_filter_option: "consultations")
      elsif parameters[:publication_filter_option] == "statistics" ||
          parameters[:controller] == "statistical_data_sets" ||
          @document && @document.try(:statistics?) # rubocop:disable Rails/HelperInstanceVariable
        publications_path(publication_filter_option: "statistics")
      else
        publications_path
      end
    when "site"
      root_path
    when "statistics", "statistics_announcements"
      statistics_path
    when "take_part_pages"
      get_involved_path
    when "world_locations", "worldwide_organisations", "worldwide_offices"
      world_locations_path(locale: :en)
    end
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
