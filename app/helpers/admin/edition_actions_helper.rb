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
        type_options_container(user).map do |text, value|
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
          value = "publication_#{sub_type.id}"
          {
            text: sub_type.plural_name,
            value:,
            selected: selected == value,
          }
        end,
      ],
      [
        "Speech sub-types",
        SpeechType.all.map do |sub_type|
          value = "speech_#{sub_type.id}"
          {
            text: sub_type.plural_name,
            value:,
            selected: selected == value,
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
end
