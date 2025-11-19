class Admin::NewDocumentController < Admin::BaseController
  def index
    @document_types = types_hash.select { |_type_key, type_hash| type_hash["klass"].enforcer(current_user).can?(:create) }
  end

  def new_document_options_redirect
    if params[:new_document_options].present?
      new_document_type_key = types_hash.keys.find { |type_key| type_key == params[:new_document_options] }
      render "admin/errors/not_found", status: :not_found unless new_document_type_key

      if types_hash[new_document_type_key].key?("redirect")
        redirect_to types_hash[new_document_type_key]["redirect"]
      else
        redirect_to send("new_admin_#{new_document_type_key}_path")
      end
    else
      redirect_to admin_new_document_path, alert: "Please select a new document option"
    end
  end

  def types_hash
    types = {
      "call_for_evidence" => {
        "klass" => CallForEvidence,
        "hint_text" => "Use this to request people's views when it is not a consultation.",
        "label" => "call_for_evidence".humanize,
      },
      "case_study" => {
        "klass" => CaseStudy,
        "hint_text" => "Use this to share real examples that help users understand a process or an important aspect of government policy covered on GOV.UK.",
        "label" => "case_study".humanize,
      },
      "consultation" => {
        "klass" => Consultation,
        "hint_text" => "Use this for documents requiring a collective agreement across government, and requests for people's view on a question with an outcome.",
        "label" => "consultation".humanize,
      },
      "detailed_guide" => {
        "klass" => DetailedGuide,
        "hint_text" => "Use this to tell users the steps they need to take to complete a clearly defined task. They are usually aimed at specialist or professional audiences.",
        "label" => "detailed_guide".humanize,
      },
      "document_collection" => {
        "klass" => DocumentCollection,
        "hint_text" => "Use this to group related documents on a single page for a specific audience or around a specific theme.",
        "label" => "document_collection".humanize,
      },
      "fatality_notice" => {
        "klass" => FatalityNotice,
        "hint_text" => "Use this to provide official confirmation of the death of a member of the armed forces while on deployment. Ministry of Defence only.",
        "label" => "fatality_notice".humanize,
      },
      "news_article" => {
        "klass" => StandardEdition,
        "hint_text" => "Use this for news story, press release, government response, and world news story.",
        "label" => "news_article".humanize,
        "redirect" => choose_type_admin_standard_editions_path(group: "news_article"),
      },
      "publication" => {
        "klass" => Publication,
        "hint_text" => "Use this for standalone government documents, white papers, strategy documents, and reports.",
        "label" => "publication".humanize,
      },
      "speech" => {
        "klass" => Speech,
        "hint_text" => "Use this for speeches by ministers or other named spokespeople, and ministerial statements to Parliament.",
        "label" => "speech".humanize,
      },
      "statistical_data_set" => {
        "klass" => StatisticalDataSet,
        "hint_text" => "Use this for data that you publish monthly or more often without analysis.",
        "label" => "statistical_data_set".humanize,
      },
      "worldwide_organisation" => {
        "klass" => WorldwideOrganisation,
        "hint_text" => "Use this to create a new worldwide organisation page. Do not create a worldwide organisation unless you have permission from your managing editor or GOV.UK department lead.",
        "label" => "worldwide_organisation".humanize,
      },
      "landing_page" => {
        "klass" => LandingPage,
        "hint_text" => "EXPERIMENTAL Use this to create landing pages.",
        "label" => "landing_page".humanize,
      },
    }
    if Flipflop.enabled?(:configurable_document_types)
      types["standard_edition"] = {
        "klass" => StandardEdition,
        "hint_text" => "EXPERIMENTAL - DEVELOPERS ONLY Use this to create config-driven documents.",
        "label" => "Standard document",
        "redirect" => choose_type_admin_standard_editions_path(group: "all"),
      }
    end
    types
  end
end
