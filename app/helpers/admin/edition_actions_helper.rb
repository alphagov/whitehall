module Admin::EditionActionsHelper
  def filter_edition_type_options_for_select(user, selected)
    options_for_select([["All types", ""]]) + edition_type_options_for_select(user, selected) + edition_sub_type_options_for_select(selected)
  end

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
        "News article sub-types",
        NewsArticleType.all.map do |sub_type|
          value = "news_article_#{sub_type.id}"
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

  def edition_type_options_for_select(user, selected)
    options_for_select(type_options_container(user), selected)
  end

  def type_options_container(user)
    Whitehall.edition_classes.map { |edition_type|
      next if edition_type == FatalityNotice && !user.can_handle_fatalities?
      next if edition_type == LandingPage && !user.gds_admin?

      [edition_type.format_name.humanize.pluralize, edition_type.model_name.singular]
    }.compact
  end

  def edition_sub_type_options_for_select(selected)
    subtype_options_hash = {
      "Publication sub-types" => PublicationType.ordered_by_prevalence.map { |sub_type| [sub_type.plural_name, "publication_#{sub_type.id}"] },
      "News article sub-types" => NewsArticleType.all.map { |sub_type| [sub_type.plural_name, "news_article_#{sub_type.id}"] },
      "Speech sub-types" => SpeechType.all.map { |sub_type| [sub_type.plural_name, "speech_#{sub_type.id}"] },
    }
    grouped_options_for_select(subtype_options_hash, selected)
  end

  def root_taxon_paths(edition_taxons)
    edition_taxons
      .map(&method(:get_root))
      .map(&:base_path)
      .uniq
      .map(&method(:delete_leading_slash))
      .sort.join(", ")
  end

  def delete_leading_slash(str)
    str.delete_prefix("/")
  end

  def get_root(taxon)
    return taxon if taxon.parent_node.nil?

    get_root(taxon.parent_node)
  end
end
