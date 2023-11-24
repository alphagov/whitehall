class Admin::NewDocumentController < Admin::BaseController
  def index; end

  def new_document_options_redirect
    if params[:new_document_options].present?
      new_document_type = params.require(:new_document_options).to_sym
      redirect_to redirect_path(new_document_type)
    else
      redirect_to admin_new_document_path, alert: "Please select a new document option"
    end
  end

private

  def check_new_design_system_permissions
    forbidden! unless new_design_system?
  end

  def get_layout
    design_system_actions = %w[index new_document_options_redirect] if preview_design_system?(next_release: false)

    if design_system_actions&.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def redirect_path(new_document_type)
    redirect_options = {
      call_for_evidence: new_admin_call_for_evidence_path,
      case_study: new_admin_case_study_path,
      consultation: new_admin_consultation_path,
      detailed_guide: new_admin_detailed_guide_path,
      document_collection: new_admin_document_collection_path,
      fatality_notice: new_admin_fatality_notice_path,
      news_article: new_admin_news_article_path,
      publication: new_admin_publication_path,
      speech: new_admin_speech_path,
      statistical_data_set: new_admin_statistical_data_set_path,
    }
    redirect_options[new_document_type]
  end
end
