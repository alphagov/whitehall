module Admin::NewDocumentHelper
  NEW_DOCUMENT_LIST = [
    Consultation,
    Publication,
    NewsArticle,
    Speech,
    DetailedGuide,
    DocumentCollection,
    FatalityNotice,
    CaseStudy,
    StatisticalDataSet,
    CallForEvidence,
  ].freeze

  def new_document_type_list
    NEW_DOCUMENT_LIST
      .select { |edition_type| can?(:create, edition_type) }
      .map do |edition_type|
      title_value = edition_type.name.underscore
      title_label = title_value.humanize
      {
        value: title_value,
        text: title_label,
        bold: true,
        hint_text: hint_text(title_value.to_sym),
      }
    end
  end

private

  def hint_text(new_document_type)
    hint_text = {
      call_for_evidence: "Use this to request people's views when it is not a consultation.",
      case_study: "Use this to share real examples that help users understand a process or an important aspect of government policy covered on GOV.UK.",
      consultation: "Use this for documents requiring a collective agreement across government, and requests for people's view on a question with an outcome.",
      detailed_guide: "Use this to tell users the steps they need to take to complete a clearly defined task. They are usually aimed at specialist or professional audiences.",
      document_collection: "Use this to group related documents on a single page for a specific audience or around a specific theme.",
      fatality_notice: "Use this to provide official confirmation of the death of a member of the armed forces while on deployment. Ministry of Defence only.",
      news_article: "Use this for news story, press release, government response, and world news story.",
      publication: "Use this for standalone government documents, white papers, strategy documents, and reports.",
      speech: "Use this for speeches by ministers or other named spokespeople, and ministerial statements to Parliament.",
      statistical_data_set: "Use this for data that you publish monthly or more often without analysis.",
    }
    hint_text[new_document_type]
  end
end
