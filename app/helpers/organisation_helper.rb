module OrganisationHelper
  def organisation_display_name(organisation)
    if organisation.acronym.present?
      tag.abbr(organisation.acronym, title: organisation.name)
    else
      organisation.name
    end
  end

  def organisation_logo_name(organisation, stacked: true)
    if stacked
      format_with_html_line_breaks(ERB::Util.html_escape(organisation.logo_formatted_name))
    else
      organisation.name
    end
  end

  def organisation_type_name(organisation)
    ActiveSupport::Inflector.singularize(organisation.organisation_type.name.downcase)
  end

  def organisation_display_name_and_parental_relationship(organisation)
    name = ERB::Util.h(organisation_display_name(organisation))
    type_name = organisation_type_name(organisation)
    relationship = ERB::Util.h(add_indefinite_article(type_name))
    parents = organisation.parent_organisations.map { |parent| organisation_relationship_html(parent) }

    description = if parents.any?
                    case type_name
                    when "other"
                      "#{name} works with #{parents.to_sentence}."
                    when "non-ministerial department"
                      "#{name} is #{relationship}."
                    when "sub-organisation"
                      "#{name} is part of #{parents.to_sentence}."
                    when "executive non-departmental public body", "advisory non-departmental public body", "tribunal non-departmental public body", "executive agency", "special health authority"
                      "#{name} is #{relationship}, sponsored by #{parents.to_sentence}."
                    else
                      "#{name} is #{relationship} of #{parents.to_sentence}."
                    end
                  else
                    type_name != "other" ? "#{name} is #{relationship}." : name.to_s
                  end

    description.html_safe
  end

  def organisation_display_name_including_parental_and_child_relationships(organisation)
    organisation_name = organisation_display_name_and_parental_relationship(organisation)
    child_organisations = organisation.supporting_bodies

    if child_organisations.any?
      organisation_name.chomp!(".")
      organisation_name += organisation_type_name(organisation) != "other" ? ", supported by " : " is supported by "

      child_relationships_link_text = child_organisations.size.to_s
      child_relationships_link_text += child_organisations.size == 1 ? " public body" : " agencies and public bodies"

      organisation_name += link_to(child_relationships_link_text, organisation.link_to_section_on_organisation_list_page, class: "brand__color")

      organisation_name += "."
    end

    organisation_name.html_safe
  end

  def organisation_relationship_html(organisation)
    prefix = needs_definite_article?(organisation.name) ? "the " : ""
    (prefix + link_to(organisation.name, organisation.public_path, class: "brand__color"))
  end

  def needs_definite_article?(phrase)
    exceptions = [/civil service resourcing/, /^hm/, /ordnance survey/]
    !has_definite_article?(phrase) && !(exceptions.any? { |e| e =~ phrase.downcase })
  end

  def has_definite_article?(phrase)
    phrase.downcase.strip[0..2] == "the"
  end

  def add_indefinite_article(noun)
    indefinite_article = starts_with_vowel?(noun) ? "an" : "a"
    "#{indefinite_article} #{noun}"
  end

  def starts_with_vowel?(word_or_phrase)
    "aeiou".include?(word_or_phrase.downcase[0])
  end

  def organisation_wrapper(organisation, _options = {}, &block)
    classes = [organisation.slug, organisation_brand_colour_class(organisation)]
    classes << organisation.organisation_type.name.parameterize if organisation.respond_to?(:organisation_type)
    content_tag_for :div, organisation, class: classes.join(" "), &block
  end

  def organisation_brand_colour_class(organisation)
    if organisation.organisation_brand_colour
      "#{organisation.organisation_brand_colour.class_name}-brand-colour"
    else
      ""
    end
  end

  def has_any_transparency_pages?(organisation)
    organisation.corporate_information_pages.any? ||
      organisation.has_published_publications_of_type?(PublicationType::FoiRelease) ||
      organisation.has_published_publications_of_type?(PublicationType::TransparencyData)
  end

  def filter_terms(organisation)
    [organisation.slug, organisation.name, organisation.acronym].join(" ")
  end

  def organisations_grouped_by_type(organisations)
    organisations.group_by(&:organisation_type).sort_by { |type, _department| type.listing_position }
  end

  def extra_board_member_class(organisation, index)
    clear_number = 3
    if organisation.important_board_members > 1
      clear_number = 4
    end
    (index % clear_number).zero? ? "clear-person" : ""
  end

  def array_of_links_to_organisations(organisations)
    organisations.map do |organisation|
      link_to organisation.name, organisation, class: "organisation-link govuk-link"
    end
  end

  def organisation_count_paragraph(org_array)
    contents = tag.span(org_array.length, class: "count js-filter-count")
    tag.p(contents.html_safe)
  end

  def show_corporate_information_pages?(organisation)
    organisation.live? && (!organisation.court_or_hmcts_tribunal? ||
      organisation.corporate_information_pages.published.reject { |cip| cip.slug == "about" }.any?)
  end

  def organisation_index_rows(user_organisation, organisations)
    organisations = ([user_organisation] + organisations).compact

    organisations.each_with_index.map do |organisation, index|
      font_weight_bold = user_organisation && index.zero? ? "govuk-!-font-weight-bold" : nil

      [
        {
          text: (if organisation.acronym.present?
                   link_to(
                     organisation.acronym,
                     admin_organisation_path(organisation),
                     class: "govuk-link #{font_weight_bold}".strip,
                   )
                 end) || "",
        },
        {
          text: link_to(
            organisation.name,
            admin_organisation_path(organisation),
            class: "govuk-link #{font_weight_bold}".strip,
          ),
        },
        {
          text: tag.p(
            organisation.organisation_type.name,
            class: "#{font_weight_bold} govuk-!-margin-bottom-0 govuk-!-margin-top-0".strip,
          ),
        },
        {
          text: tag.p(
            organisation.govuk_status,
            class: "#{font_weight_bold} govuk-!-margin-bottom-0 govuk-!-margin-top-0".strip,
          ),
        },
        {
          text: link_to("[gov.uk]", organisation.public_path, class: "govuk-link #{font_weight_bold}".strip) +
            (link_to("[current site]", organisation.url, class: "govuk-link #{font_weight_bold}".strip) if organisation.govuk_status != "live"),
        },
      ]
    end
  end
end
