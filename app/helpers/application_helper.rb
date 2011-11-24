module ApplicationHelper
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

  def empty_documents_list_verb(document_state)
    if document_state.downcase == "draft"
      "drafted"
    else
      document_state.downcase
    end
  end

  def ministerial_appointment_options
    MinisterialRole.joins(:current_role_appointments).alphabetical_by_person.map do |role|
      [role.current_role_appointment.id, role.to_s]
    end
  end

  def image_for_ministerial_role(ministerial_role)
    url = ministerial_role.current_person_image_url || "/assets/blank-person.jpg"
    url = "http://mustachify.me/?src=" + url if params[:plummy]
    image_tag url
  end

  def render_list_of_roles(roles, class_name = "ministerial_roles", &block)
    raise ArgumentError, "please supply the content of the list item" unless block_given?
    content_tag(:ul, class: class_name) do
      roles.each do |role|
        li = content_tag_for(:li, role) do
          block.call(role).html_safe
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
end
