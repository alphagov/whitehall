require_relative "mocha"

Before do
  type_definition = JSON.parse(File.read(Rails.root.join("features/fixtures/test_configurable_document_type.json")))
  ConfigurableDocumentType.setup_test_types({ "test_type" => type_definition })
  ConfigurableDocumentType.stubs(:find).returns(ConfigurableDocumentType.new(type_definition))

  DocumentTypesConcern.module_eval do
    def all_standard_document_types
      {
        "test_type" => {
          "klass" => StandardEdition,
          "hint_text" => ConfigurableDocumentType.find("test_type").description,
          "label" => ConfigurableDocumentType.find("test_type").label,
          "redirect" => new_admin_standard_edition_path(configurable_document_type: "test_type"),
          "requires_feature_flag" => :configurable_document_types,
        },
        "call_for_evidence" => {
          "klass" => CallForEvidence,
          "hint_text" => "Use this to request people's views when it is not a consultation.",
          "label" => "call_for_evidence".humanize,
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
  end
end
