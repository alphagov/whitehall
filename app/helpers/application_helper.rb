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

  def not_on_login_page?
    request.path != login_path
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
    string.split(/(\r?\n){2}/).collect{|paragraph| "<p>#{paragraph}</p>" }.join.html_safe
  end

  def govspeak_to_html(text)
    Govspeak::Document.new(text).to_html.html_safe
  end

  def link_to_attachment(attachment)
    return unless attachment && attachment.name.present?
    link_to File.basename(attachment.name.current_path), attachment.name.url
  end

  def empty_documents_list_verb(document_state)
    if document_state.downcase == "draft"
      "drafted"
    else
      document_state.downcase
    end
  end

  def admin_policy_path(*args)
    admin_document_path(*args)
  end

  def admin_publication_path(*args)
    admin_document_path(*args)
  end

  def admin_policies_path(*args)
    admin_documents_path(*args)
  end

  def admin_publications_path(*args)
    admin_documents_path(*args)
  end

  def admin_policy_fact_check_requests_path(*args)
    admin_document_fact_check_requests_path(*args)
  end

  def admin_publication_fact_check_requests_path(*args)
    admin_document_fact_check_requests_path(*args)
  end

  def admin_policy_fact_check_request_path(*args)
    admin_document_fact_check_request_path(*args)
  end

  def admin_policy_supporting_documents_path(*args)
    admin_document_supporting_documents_path(*args)
  end
end
