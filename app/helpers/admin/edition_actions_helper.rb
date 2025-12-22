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
        ConfigurableDocumentType.where_group("news_article").map do |sub_type|
          {
            text: sub_type.label.pluralize,
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

  def legacy_types_options(user)
    legacy_classes = Whitehall.legacy_edition_classes
    legacy_classes.map { |edition_type|
      next if edition_type == FatalityNotice && !user.can_handle_fatalities?
      next if edition_type == LandingPage && !user.gds_admin?

      [edition_type.format_name.humanize.pluralize, edition_type.model_name.singular]
    }.compact
  end

  def configurable_document_type_options
    groups = []
    types_with_no_groups = ConfigurableDocumentType
                             .all
                             .reject { |doc|
                               groups << doc.settings["configurable_document_group"] if doc.settings["configurable_document_group"].present?
                               doc.settings["configurable_document_group"]
                             }
                             .map { |doc| [doc.label.pluralize, doc.key] }

    types_with_no_groups + groups.uniq.map { |group| [group.humanize.pluralize, group] }
  end

  def combined_list_of_document_types(user)
    (legacy_types_options(user) + configurable_document_type_options)
      .uniq
      .sort_by { |text, _value| text.to_s.downcase }
  end
end
