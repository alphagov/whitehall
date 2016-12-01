module ApplicationHelper

  def policies_path
    "/government/policies"
  end

  def policies_finder_path(query_params)
    "#{policies_path}?#{query_params.to_query}"
  end

  def page_title(*title_parts)
    if title_parts.any?
      title_parts.push("Admin") if params[:controller] =~ /^admin\//
      title_parts.push("GOV.UK")
      @page_title = title_parts.reject { |p| p.blank? }.join(" - ")
    else
      @page_title
    end
  end

  def meta_description_tag
    tag :meta, name: 'description', content: @meta_description
  end

  def page_class(css_class)
    content_for(:page_class, css_class)
  end

  def atom_discovery_link_tag(url = nil, title = nil)
    @atom_discovery_link_url = url if url.present?
    @atom_discovery_link_title = title if title.present?
    auto_discovery_link_tag(:atom, @atom_discovery_link_url || atom_feed_url(format: :atom), title: @atom_discovery_link_title || "Recent updates")
  end

  def api_link_tag(path)
    tag :link, href: path, rel: 'alternate', type: Mime::JSON
  end

  def format_in_paragraphs(string)
    safe_join (string || "").split(/(?:\r?\n){2}/).map { |paragraph| content_tag(:p, paragraph) }
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
      ["Common types", PublicationType.primary.map { |publication_type|
        [publication_type.singular_name, publication_type.id]
      }],
      ["Less common types", PublicationType.less_common.map { |publication_type|
        [publication_type.singular_name, publication_type.id]
      }],
      ["Use discouraged", PublicationType.use_discouraged.map { |publication_type|
        [publication_type.singular_name, publication_type.id]
      }]
    ]
  end

  def worldwide_office_type_options
    WorldwideOfficeType.by_grouping.map { |grouping, types|
      [
        grouping,
        types.map { |t| [t.name, t.id] }
      ]
    }
  end

  def news_article_type_options
    [
      ["", [""]],
      ["Common types", NewsArticleType.primary.map { |type|
        [type.singular_name, type.id]
      }]
    ]
  end

  def speech_type_options
    [
      ["", [""]],
      ["Common types", SpeechType.primary.map { |type|
        [type.singular_name, type.id]
      }]
    ]
  end

  def role_type_options
    RoleTypePresenter.options
  end

  def link_to_person(person)
    PersonPresenter.new(person, self).link(class: 'person-link')
  end

  def image_for_person(person)
    PersonPresenter.new(person, self).image
  end

  def render_list_of_roles(roles, class_name = "ministerial_roles", &block)
    raise ArgumentError, "please supply the content of the list item" unless block_given?
    content_tag(:ul, class: class_name) do
      roles.each do |role|
        li = content_tag_for(:li, role) do
          block.call(RolePresenter.new(role, self)).html_safe
        end.html_safe
        concat li
      end
    end
  end

  def render_list_of_ministerial_roles(ministerial_roles, &block)
    render_list_of_roles(ministerial_roles, &block)
  end

  def full_width_tabs(tab_data)
    content_tag(:nav, class: "activity-navigation") {
      content_tag(:ul) {
        tab_data.map { | tab |
          content_tag :li do
            if tab[:current_when]
              link_to tab[:label], tab[:link_to], class: ('current' if tab[:current_when])
            else
              link_to_with_current(tab[:label], tab[:link_to])
            end
          end
        }.join.html_safe
      }
    }
  end

  def link_to_with_current(name, path, options = {})
    options = options.dup
    path_matcher = options.delete(:current_path) || Regexp.new("^#{Regexp.escape(path)}$")
    css_classes = [options[:class], current_link_class(path_matcher)].join(" ").strip
    options[:class] = css_classes unless css_classes.blank?

    link_to name, path, options
  end

  def current_link_class(path_matcher)
    request.path =~ path_matcher ? 'current' : ''
  end

  def render_datetime_microformat(object, method, &block)
    content_tag(:time, class: method, datetime: object.send(method).iso8601, &block)
  end

  def absolute_time(time, options = {})
    content_tag(:time, l(time, format: :long_ordinal),
                class: [options[:class], "datetime"].compact.join(" "),
                datetime: time.iso8601) if time
  end

  def absolute_date(time, options = {})
    content_tag(:time, l(time.to_date, format: :long_ordinal),
                class: [options[:class], "date"].compact.join(" "),
                datetime: time.iso8601) if time
  end

  def main_navigation_link_to(name, path, html_options = {}, &block)
    classes = (html_options[:class] || "").split
    if current_main_navigation_path(params) == path
      classes << "active"
    end
    link_to(name, path, html_options.merge(class: classes.join(" ")), &block)
  end

  def main_navigation_documents_class
    document_paths = [publications_path, consultations_path, announcements_path, publications_path(publication_filter_option: 'consultations'), publications_path(publication_filter_option: 'statistics')]
    if document_paths.include? current_main_navigation_path(params)
      "current"
    else
      ""
    end
  end

  def current_main_navigation_path(parameters)
    case parameters[:controller]
    when "home"
      if parameters[:action] == 'home'
        root_path
      elsif parameters[:action] == 'get_involved'
          get_involved_path
      else
        how_government_works_path
      end
    when "histories", "past_foreign_secretaries", "historic_appointments"
      how_government_works_path
    when "site"
      root_path
    when "announcements", "news_articles", "speeches", "fatality_notices", "operational_fields"
      announcements_path
    when "statistics", "statistics_announcements"
      statistics_path
    when "publications", "statistical_data_sets"
      if parameters[:publication_filter_option] == 'consultations'
        publications_path(publication_filter_option: 'consultations')
      elsif parameters[:publication_filter_option] == 'statistics' ||
            parameters[:controller] == 'statistical_data_sets' ||
            @document && @document.try(:statistics?)
        publications_path(publication_filter_option: 'statistics')
      else
        publications_path
      end
    when "consultations", "consultation_responses"
      publications_path(publication_filter_option: 'consultations')
    when "ministerial_roles"
      ministerial_roles_path
    when "organisations", "groups", "email_signup_information"
      if parameters[:courts_only]
        courts_path
      else
        organisations_path
      end
    when "corporate_information_pages"
      if parameters.has_key?(:worldwide_organisation_id)
        world_locations_path
      else
        organisations_path
      end
    when "world_locations", "world_location_news_articles", "worldwide_organisations", "worldwide_offices"
      world_locations_path(locale: :en)
    when "policy_groups"
      policies_path
    when "take_part_pages"
      get_involved_path
    when "latest"
      if parameters[:departments]
        organisations_path
      elsif parameters[:world_locations]
        world_locations_path
      else
        latest_path
      end
    end
  end

  def linked_author(author, link_options = {})
    if author
      link_to(author.name, admin_author_path(author), link_options)
    else
      '-'
    end
  end

  def month_filter_options(start_date, selected_date)
    baseline = (Date.today + 1.month).beginning_of_month
    number_of_months = ((baseline.to_time - start_date.to_time) / 43829.1 / 60).round + 1
    months = (0...number_of_months).map { |i| baseline - i.months }
    options_for_select(months.map { |m| [m.to_s(:short_ordinal), m.to_s] }, selected_date.to_s)
  end

  def corporate_information_page_types(organisation)
    CorporateInformationPageType.all.map { |c| [c.title(organisation), c.id] }
  end

  def collection_list_class(items, minimum_columns = 1)
    if items.length > 8 || minimum_columns == 3
      "three-columns"
    elsif items.length > 3 || minimum_columns == 2
      "two-columns"
    else
      "one-column"
    end
  end

  def is_external?(href)
    if host = Addressable::URI.parse(href).host
      Whitehall.public_host != host
    end
  end

  def right_to_left?
    Locale.new(I18n.locale).rtl?
  end

  def content_tag_if_not_empty(name, options = nil, &block)
    content = capture do
      yield
    end
    if content.present? && content.strip
      content_tag(name, content, options)
    else
      ""
    end
  end

  def unsorted_grouped_options_for_select(grouped_options, selected_key = nil, prompt = nil)
    body = ''
    body << content_tag(:option, prompt, { value: "" }, true) if prompt

    grouped_options.each do |group, options|
      body << content_tag(:optgroup, options_for_select(options, selected_key), label: group)
    end

    body.html_safe
  end

  def render_partial_if_exists(partial)
    if lookup_context.template_exists?(partial, lookup_context.prefixes, true)
      render partial
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
end
