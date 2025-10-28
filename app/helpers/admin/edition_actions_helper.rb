module Admin::EditionActionsHelper
  def filter_edition_type_opt_groups(user, selected)
    [
      [
        "",
        [
          {
            text: "All types",
            value: "",
            selected: selected.blank?,
          },
        ],
      ],
      [
        "Types",
        combined_list_of_document_types(user).map do |text, value|
          {
            text:,
            value:,
            selected: selected == value,
          }
        end,
      ],
      [
        "Publication sub-types",
        PublicationType.ordered_by_prevalence.map do |sub_type|
          {
            text: sub_type.plural_name,
            value: sub_type.key,
            selected: selected == sub_type.key,
          }
        end,
      ],
      [
        "News article sub-types",
        NewsArticleType.all.map do |sub_type|
          {
            text: sub_type.plural_name,
            value: sub_type.key,
            selected: selected == sub_type.key,
          }
        end,
      ],
      [
        "Speech sub-types",
        SpeechType.all.map do |sub_type|
          {
            text: sub_type.plural_name,
            value: sub_type.key,
            selected: selected == sub_type.key,
          }
        end,
      ],
    ]
  end

private

  def type_options_container(user)
    Whitehall.edition_classes.map { |edition_type|
      next if edition_type == FatalityNotice && !user.can_handle_fatalities?
      next if edition_type == LandingPage && !user.gds_admin?

      [edition_type.format_name.humanize.pluralize, edition_type.model_name.singular]
    }.compact
  end

  def configurable_document_type_options
    exclude = %w[news_article speech publication]
    ConfigurableDocumentType.all.filter_map do |doc|
      schema = doc.settings["publishing_api_schema_name"]
      next if exclude.include?(schema)

      [doc.label.pluralize, doc.key]
    end
  end

  def combined_list_of_document_types(user)
    legacy_document_types = type_options_container(user)
    configurable_document_types = configurable_document_type_options

    combined = legacy_document_types + configurable_document_types

    combined.sort_by { |text, _value| text.to_s.downcase }
  end
end
