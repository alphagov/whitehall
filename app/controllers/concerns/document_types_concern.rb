module DocumentTypesConcern
  def all_standard_document_types
    {
      "call_for_evidence" => {
        "klass" => CallForEvidence,
        "hint_text" => "Use this to request people's views when it is not a consultation.",
        "label" => "call_for_evidence".humanize,
      },
      "case_study" => {
        "klass" => StandardEdition,
        "hint_text" => "Use this to share real examples that help users understand a process or an important aspect of government policy covered on GOV.UK.",
        "label" => "case_study".humanize,
        "configurable_document_type" => "case_study",
        "redirect" => new_admin_standard_edition_path(configurable_document_type: "case_study"),
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
      "standard_edition" => {
        "klass" => StandardEdition,
        "hint_text" => "EXPERIMENTAL - DEVELOPERS ONLY Use this to create config-driven documents.",
        "label" => "Standard document",
        "redirect" => choose_type_admin_standard_editions_path(group: "all"),
        "requires_feature_flag" => :configurable_document_types,
      },
    }
  end

  def all_requires_approval_document_types
    {
      "mini_site_landing" => {
        "klass" => StandardEdition,
        "hint_text" => ConfigurableDocumentType.find("mini_site_landing").description,
        "label" => ConfigurableDocumentType.find("mini_site_landing").label,
        "configurable_document_type" => "mini_site_landing",
        "redirect" => new_admin_standard_edition_path(configurable_document_type: "mini_site_landing"),
        "requires_feature_flag" => :configurable_document_types,
      },
      "topical_event" => {
        "klass" => StandardEdition,
        "hint_text" => ConfigurableDocumentType.find("topical_event").description,
        "label" => ConfigurableDocumentType.find("topical_event").label,
        "configurable_document_type" => "topical_event",
        "redirect" => new_admin_standard_edition_path(configurable_document_type: "topical_event"),
      },
    }
  end

  def standard_document_types
    all_standard_document_types.select(&method(:valid_document_type?))
  end

  def requires_approval_document_types
    all_requires_approval_document_types.select(&method(:valid_document_type?))
  end

  def permitted_document_types
    standard_document_types.merge(requires_approval_document_types)
  end

  def document_type_redirect(document_type)
    document_type["redirect"]
  end

  def valid_document_type?(document_type_key, document_type)
    document_type_createable_by_user?(document_type) &&
      document_type_available_for_user?(document_type) &&
      document_type_feature_flag_enabled?(document_type)
  end

private

  def document_type_feature_flag_enabled?(document_type)
    document_type["requires_feature_flag"].nil? || Flipflop.enabled?(document_type["requires_feature_flag"])
  end

  def document_type_available_for_user?(document_type)
    return true unless document_type["configurable_document_type"]

    can?(current_user, ConfigurableDocumentType.find(document_type["configurable_document_type"]))
  end

  def document_type_createable_by_user?(document_type)
    document_type["klass"].enforcer(current_user).can?(:create)
  end
end
