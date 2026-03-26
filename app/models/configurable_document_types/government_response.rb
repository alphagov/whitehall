ConfigurableDocumentTypes::GovernmentResponse = ConfigurableDocumentTypeConfig.new.build do
  key "government_response"
  title "Government response"
  description "Government statements in response to media coverage, such as rebuttals and ‘myth busters’. Do not use for: statements to Parliament. Use the ‘Speech’ format for those."
  form("documents") do
    field "body", "govspeak", %w[block_content body] do
      title "Body"
      description "The main content of the page"
      required
      translatable
    end
    field "ministerial_role_appointments", "select_with_search_tagging", %w[role_appointment_ids] do
      title "Ministers"
      container "ministerial_role_appointments"
    end
  end

  schema do
    attribute :body, :string
    validates :body, presence: true, length: { maximum: 16_777_215 }
  end

  presenter("publishing_api") do
    body { |item| item.block_content.body }
    link :ministerial_role_appointments
  end

  settings do
    {
      "base_path_prefix" => "/government/news",
      "configurable_document_group" => "news_article",
      "publishing_api_schema_name" => "news_article",
      "publishing_api_document_type" => "government_response",
      "rendering_app" => "frontend",
      "images" => {
        "enabled" => true,
        "usages" => {
          "govspeak_embed" => {
            "kinds" => %w[default],
            "multiple" => true,
          },
          "lead" => {
            "label" => "lead",
            "kinds" => %w[default],
            "multiple" => false,
          },
        },
      },
      "send_change_history" => true,
      "file_attachments_enabled" => true,
      "organisations" => nil,
      "backdating_enabled" => true,
      "history_mode_enabled" => true,
      "translations_enabled" => true,
    }
  end
end
