class Admin::NewDocumentController < Admin::BaseController
  before_action :check_new_design_system_permissions, only: %i[index]

  layout :get_layout

  def index; end

  def new_document_options_redirect
    redirect_options = {
      "call-for-evidence": new_admin_call_for_evidence_path,
      "case-study": new_admin_case_study_path,
      "consultation": new_admin_consultation_path,
      "detailed-guide": new_admin_detailed_guide_path,
      "document-collection": new_admin_document_collection_path,
      "fatality-notice": new_admin_fatality_notice_path,
      "news-article": new_admin_news_article_path,
      "publication": new_admin_publication_path,
      "speech": new_admin_speech_path,
      "statistical-data-set": new_admin_statistical_data_set_path,
    }

    if params[:new_document_options].present?
      selected_option = params.require(:new_document_options).to_sym
      redirect_to redirect_options[selected_option]
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
end
