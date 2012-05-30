module Admin::EditionRoutesHelper
  EDITION_TYPES = [Policy, Publication, NewsArticle, Consultation, Speech, InternationalPriority]

  def self.edition_instance_route(name)
    document_instance_route(name, "admin_edition")
  end

  def self.document_instance_route(name, prefix = "admin_document")
    EDITION_TYPES.each do |type|
      method_name = name.to_s.gsub(prefix, "admin_#{type.model_name.singular}")
      class_eval %{
        def #{method_name}(*args)
          #{name}(*args)
        end
      }
    end
  end

  edition_instance_route :admin_edition_supporting_pages_path

  document_instance_route :admin_document_fact_check_requests_path
  document_instance_route :admin_document_editorial_remarks_path

  def admin_document_path(edition, *args)
    if edition.is_a?(Speech)
      admin_speech_path(edition, *args)
    else
      polymorphic_path([:admin, edition], *args)
    end
  end

  def admin_document_url(edition, *args)
    if edition.is_a?(Speech)
      admin_speech_url(edition, *args)
    else
      polymorphic_url([:admin, edition], *args)
    end
  end

  def edit_admin_document_path(edition, *args)
    if edition.is_a?(Speech)
      edit_admin_speech_path(edition, *args)
    else
      polymorphic_path([:edit, :admin, edition], *args)
    end
  end
end