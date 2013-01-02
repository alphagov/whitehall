module ApplicationHelper
  def page_title(*title_parts)
    if title_parts.any?
      title_parts.push("Admin") if params[:controller] =~ /^admin\//
      title_parts.push("Inside Government") if params[:controller] !~ /^detailed_guides/
      title_parts.push("GOV.UK")
      @page_title = title_parts.reject { |p| p.blank? }.join(" - ")
    else
      @page_title
    end
  end

  def page_class(css_class)
    content_for(:page_class, css_class)
  end

  def atom_discovery_link_tag(url=nil, title=nil)
    @atom_discovery_link_url = url if url.present?
    @atom_discovery_link_title = title if title.present?
    auto_discovery_link_tag(:atom, @atom_discovery_link_url || atom_feed_url(format: :atom), title: @atom_discovery_link_title || "Recent updates")
  end

  def api_link_tag(path)
    tag :link, href: path, rel: 'alternate', type: Mime::JSON
  end

  def filter_atom_feed_url
    url_for(params.except(:utf8, :_, :date, :direction, :page).merge(format: "atom", only_path: false))
  end

  def filter_json_url(args={})
    url_for(params.except(:utf8, :_).merge(format: "json").merge(args))
  end

  def format_in_paragraphs(string)
    safe_join (string||"").split(/(?:\r?\n){2}/).collect { |paragraph| content_tag(:p, paragraph) }
  end

  def format_with_html_line_breaks(string)
    (h(string)||"").gsub(/(?:\r?\n)/, "<br/>").html_safe
  end

  def link_to_attachment(attachment)
    return unless attachment
    link_to attachment.filename, attachment.url
  end

  def role_appointment(appointment, link=false)
    link = false unless appointment.role.ministerial?
    role_text = (link ? link_to(appointment.role.name, appointment.role) : appointment.role.name)
    if appointment.current?
      role_text.html_safe
    else
      ended = appointment.ended_at ? l(appointment.ended_at.to_date) : 'present'
      "as #{role_text} (#{l(appointment.started_at.to_date)} to #{ended})".html_safe
    end
  end

  def ministerial_appointment_options
    role_appointment_options(RoleAppointment.for_ministerial_roles)
  end

  def role_appointment_options(filter = RoleAppointment)
    filter.alphabetical_by_person.map do |appointment|
      [appointment.id, "#{appointment.person.name}, #{role_appointment(appointment)}, in #{appointment.role.organisations.collect(&:name).to_sentence}"]
    end
  end

  def statistical_data_set_options
    StatisticalDataSet.latest_edition.map do |data_set|
      [data_set.document_id, data_set.title]
    end
  end

  def ministerial_role_options
    MinisterialRole.alphabetical_by_person.map do |role|
      [role.id, "#{role.name}, in #{role.organisations.collect(&:name).to_sentence} (#{role.current_person_name})"]
    end
  end

  def related_policy_options
    Policy.latest_edition.active.map do |policy|
      parts = [policy.title]
      parts << "(#{policy.topics.map(&:name).to_sentence})" if policy.topics.any?
      [policy.document_id, parts.join(" ")]
    end
  end

  def publication_type_options
    [
      ["", [""]],
      ["Common types", (PublicationType.primary - [PublicationType::Consultation]).map { |publication_type|
        [publication_type.singular_name, publication_type.id]
      }],
      ["Less common types", PublicationType.less_common.map { |publication_type|
        [publication_type.singular_name, publication_type.id]
      }],
      ["Use discouraged", PublicationType.use_discouraged.map { |publication_type|
        [publication_type.singular_name, publication_type.id]
      }],
      ["Legacy (need migration)", PublicationType.migration.map { |publication_type|
        [publication_type.singular_name, publication_type.id]
      }]
    ]
  end

  def role_type_options
    RoleTypePresenter.options
  end

  def role_type_option_value_for(role, role_type)
    RoleTypePresenter.option_value_for(role, role_type)
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

  def absolute_date(time, options = {})
    content_tag(:abbr, time.to_date.to_s(:long_ordinal),
                class: [options[:class], "date"].compact.join(" "),
                title: time.iso8601)
  end

  def main_navigation_link_to(name, path, html_options = {}, &block)
    classes = (html_options[:class] || "").split
    if current_main_navigation_path(params) == path
      classes << "current"
    end
    link_to(name, path, html_options.merge(class: classes.join(" ")), &block)
  end

  def main_navigation_documents_class
    document_paths = [publications_path, consultations_path, announcements_path]
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
      else
        how_government_works_path
      end
    when "site"
        root_path
    when "announcements", "news_articles", "speeches"
      announcements_path
    when "topics"
      topics_path
    when "publications"
      publications_path
    when "consultations", "consultation_responses"
      consultations_path
    when "ministerial_roles"
      ministerial_roles_path
    when "organisations", "corporate_information_pages"
      organisations_path
    when "world_locations", "international_priorities"
      world_locations_path
    when "policies", "supporting_pages"
      policies_path
    end
  end

  def progress_bar_link
    unless params[:controller] == "home" && params[:action] == "home"
      link_to "More will join soon", root_path
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

  def linked_author(author)
    link_to(author.name, admin_author_path(author))
  end

  def recent_month_filter_options(number_of_months, selected_date)
    baseline = (Date.today + 1.month).beginning_of_month
    months = (0...number_of_months).map { |i| baseline - i.months }
    options_for_select(months.map { |m| [m.strftime("%B %Y"), m.to_s] }, selected_date.to_s)
  end

  def corporate_information_page_types(organisation)
    CorporateInformationPageType.all.map {|c| [c.title(organisation), c.id]}
  end

  def mainstream_category_path(category)
    url_for(controller: '/mainstream_categories', action: :show, id: category, parent_tag: category.parent_tag, only_path: true)
  end

  def collection_list_class(items, minimum_columns=1)
    if items.length > 8 || minimum_columns == 3
      "three-columns"
    elsif items.length > 3 || minimum_columns == 2
      "two-columns"
    else
      "one-column"
    end
  end

  def path_to_image(source)
    if source.starts_with?("/government/uploads") && user_signed_in?
      source
    else
      super(source)
    end
  end

  def ministerial_department_type_id
    @ministerial_department_type_id ||= OrganisationType.find_by_name('Ministerial department')
  end

  def ministerial_department_count
    @ministerial_department_count ||= Organisation.where(organisation_type_id: ministerial_department_type_id).count
  end

  def joined_ministerial_department_count
    @joined_ministerial_department_count ||= Organisation.where("organisation_type_id = ? AND govuk_status = 'live'", ministerial_department_type_id).count
  end

  def joined_ministerial_department_percent
    number_to_percentage(100*joined_ministerial_department_count.to_f/ministerial_department_count)
  end
end
