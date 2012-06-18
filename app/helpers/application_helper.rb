module ApplicationHelper
  def page_title(*title_parts)
    if title_parts.any?
      title_parts.push("Admin") if params[:controller] =~ /^admin\//
      title_parts.push("Inside Government")
      title_parts.push("GOV.UK Beta (Test)")
      @page_title = title_parts.reject { |p| p.blank? }.join(" | ")
    else
      @page_title
    end
  end

  def page_class(css_class)
    content_for(:page_class, css_class)
  end

  def show_session_controls?
    params[:controller].split("/").first == "admin" ||
    params[:controller] == "sessions"
  end

  def labelled_check_box(object_name, attribute, text)
    for_attribute = [object_name, attribute].map(&:to_s).join("_")
    label_tag "", {for: for_attribute, class: "for_checkbox"} do
      check_box(object_name, attribute) +
      "&nbsp;".html_safe +
      content_tag(:span, text)
    end
  end

  def format_in_paragraphs(string)
    safe_join (string||"").split(/(?:\r?\n){2}/).collect { |paragraph| content_tag(:p, paragraph) }
  end

  def format_with_html_line_breaks(string)
    (string||"").gsub(/(?:\r?\n)/, "<br/>").html_safe
  end

  def link_to_attachment(attachment)
    return unless attachment
    link_to attachment.filename, attachment.url
  end

  def publication_summary(publication)
    if publication.summary.present?
      publication.summary
    else
      truncate(publication.body, { length: 200 })
    end
  end

  def role_appointment(appointment, link=false)
    role_text = (link ? link_to(appointment.role.name, appointment.role) : appointment.role.name)
    if appointment.current?
      role_text.html_safe
    else
      ended = appointment.ended_at ? l(appointment.ended_at.to_date) : 'present'
      "as #{role_text} (#{l(appointment.started_at.to_date)} to #{ended})".html_safe
    end
  end

  def ministerial_appointment_options
    RoleAppointment.for_ministerial_roles.alphabetical_by_person.map do |appointment|
      [appointment.id, "#{appointment.person.name}, #{role_appointment(appointment)}, in #{appointment.role.organisations.collect(&:name).to_sentence}"]
    end
  end

  def ministerial_role_options
    MinisterialRole.alphabetical_by_person.map do |role|
      [role.id, "#{role.name}, in #{role.organisations.collect(&:name).to_sentence} (#{role.current_person_name})"]
    end
  end

  def link_to_person(person)
    PersonPresenter.new(person).link
  end

  def image_for_person(person)
    PersonPresenter.new(person).image
  end

  def render_list_of_roles(roles, class_name = "ministerial_roles", &block)
    raise ArgumentError, "please supply the content of the list item" unless block_given?
    content_tag(:ul, class: class_name) do
      roles.each do |role|
        li = content_tag_for(:li, role) do
          block.call(RolePresenter.new(role)).html_safe
        end.html_safe
        concat li
      end
    end
  end

  def render_list_of_ministerial_roles(ministerial_roles, &block)
    render_list_of_roles(ministerial_roles, &block)
  end

  def link_to_with_current(name, path, options={})
    path_matcher = options.delete(:current_path) || Regexp.new("^#{Regexp.escape(path)}$")
    css_classes = [options[:class], current_link_class(path_matcher)].join(" ").strip
    options[:class] = css_classes unless css_classes.blank?

    link_to name, path, options
  end

  def current_link_class(path_matcher)
    request.path =~ path_matcher ? 'current' : ''
  end

  def human_friendly_edition_type(edition)
    edition.type.tableize.singularize.humanize
  end

  def yes_or_no(boolean)
    boolean ? "Yes" : "No"
  end

  def render_datetime_microformat(object, method, &block)
    content_tag(:abbr, class: method, title: object.send(method).iso8601, &block)
  end

  def relative_time(time, options = {})
    content_tag(:abbr, time.to_s(:long_ordinal),
                class: [options[:class], "datetime", "time_ago"].compact.join(" "),
                title: time.iso8601)
  end

  def absolute_time(time, options = {})
    content_tag(:abbr, time.to_s(:long_ordinal),
                class: [options[:class], "datetime"].compact.join(" "),
                title: time.iso8601)
  end

  def main_navigation_link_to(name, path, html_options = {}, &block)
    classes = (html_options[:class] || "").split
    if current_main_navigation_path(params) == path
      classes << "current"
    end
    link_to(name, path, html_options.merge(class: classes.join(" ")), &block)
  end

  def current_main_navigation_path(parameters)
    case parameters[:controller]
    when "site"
      home_path
    when "announcements", "news_articles", "speeches"
      announcements_path
    when "topics", "policies", "supporting_pages"
      topics_path
    when "publications"
      publications_path
    when "consultations", "consultation_responses"
      consultations_path
    when "ministerial_roles"
      ministerial_roles_path
    when "organisations"
      organisations_path
    when "countries", "international_priorities"
      countries_path
    end
  end

  def featured_grid_class(count=0)
    case count
    when 1
      "g3"
    when 2
      "g-half"
    when 3
      "g1"
    end
  end

  def article_section(title, collection, options = {}, &block)
    content_tag(:section, id: options[:id], class: ["article_section", options[:class]]) do
      concat content_tag(:h1, title)
      article_group(collection, groups_of: 3, class: "row", article: { class: options[:article_class], wrapper_class: options[:article_wrapper_class] }, &block)
      concat content_tag(:p, options[:more], class: "readmore") if options[:more]
    end
  end

  def article_group(items, options = {}, &block)
    options = options.reverse_merge({ article: { wrapper_class: "g1" }})

    article_groups = items.in_groups_of(options[:groups_of], false)
    article_groups.each_with_index do |article_group, index|
      row_class = ["group", options[:class]]
      row_class << "last" if index == article_groups.length-1
      row = content_tag(:div, class: row_class.compact.join(" ")) do
        article_group.each do |item|
          div = content_tag(:div, class: options[:article][:wrapper_class]) do
            css_classes = (options[:article][:class] || "") + " " + edition_organisation_class(item)
            article = content_tag_for(:article, item, class: css_classes) do
              block.call(item).html_safe
            end.html_safe
            concat article
          end
          concat div
        end
      end
      concat row
    end
  end

  def in_columns(collection, num_columns, &block)
    items = collection.to_a
    n = items.length
    a = n / num_columns
    b = n % num_columns
    num_columns.times.map { |i|
      yield items.shift(a + (i < b ? 1 : 0))
    }
  end

  def featured_carousel_classes(options = {})
    classes = ["featured_carousel"]
    classes << "organisation_news" if options[:organisational_context]
    classes << "country_news" if options[:country_context]
    classes.join(" ")
  end

  def publications_page_title(topics)
    if topics.any?
      "Publications about #{
        topics.map { |t| t.name.downcase }.to_sentence }"
    else
      "Publications"
    end
  end

  def linked_author(author)
    link_to(author.name, admin_author_path(author))
  end
end
