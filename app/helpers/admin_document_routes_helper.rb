module AdminDocumentRoutesHelper
  DOCUMENT_TYPES = [Policy, Publication, NewsArticle, Consultation, Speech, InternationalPriority]

  def self.document_instance_route(name)
    DOCUMENT_TYPES.each do |type|
      method_name = name.to_s.gsub("admin_document", "admin_#{type.model_name.singular}")
      class_eval %{
        def #{method_name}(*args)
          #{name}(*args)
        end
      }
    end
  end

  document_instance_route :admin_document_fact_check_requests_path
  document_instance_route :admin_document_supporting_pages_path
  document_instance_route :admin_document_editorial_remarks_path

  def admin_document_path(document, *args)
    if document.is_a?(Speech)
      admin_speech_path(document, *args)
    else
      polymorphic_path([:admin, document], *args)
    end
  end

  def admin_document_url(document, *args)
    if document.is_a?(Speech)
      admin_speech_url(document, *args)
    else
      polymorphic_url([:admin, document], *args)
    end
  end

  def edit_admin_document_path(document, *args)
    if document.is_a?(Speech)
      edit_admin_speech_path(document, *args)
    else
      polymorphic_path([:edit, :admin, document], *args)
    end
  end
end