module ApplicationHelper

  def navigation_link(name, path, html_options = {}, &block)
    link_to_unless_current(name, path, html_options) do
       link_to(name, path, class: 'current')
    end
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

  def user_role(user)
    if user.departmental_editor?
      "departmental editor"
    else
      "policy writer"
    end
  end

  def format_in_paragraphs(string)
    (string || "").split(/(\r?\n){2}/).collect{|paragraph| "<p>#{paragraph}</p>" }.join.html_safe
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
    MinisterialRole.alphabetical_by_person.includes(:role_appointments).map do |role|
      [role.current_role_appointment.id, role.to_s]
    end
  end
end
