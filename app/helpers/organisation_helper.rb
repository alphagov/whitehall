module OrganisationHelper
  include ApplicationHelper

  # TODO: - we should also have Welsh equivalents
  PATTERNS_EXEMPT_FROM_DEFINITIVE_ARTICLE = [
    /civil service resourcing/,
    /^hm/,
    /ordnance survey/,
    /homes england/,
    /british wool/,
    /building law and hygiene/,
  ].freeze

  SPONSORED_ORGANISATION_TYPE_KEYS = %i[
    advisory_ndpb
    executive_agency
    executive_ndpb
    special_health_authority
  ].freeze

  ORGANISATIONS_WITH_NO_PARENT_RELATIONSHIP_TYPE_KEYS = %i[
    non_ministerial_department
  ].freeze

  def organisation_display_name_with_definite_article(organisation)
    if organisation.acronym.present?
      tag.abbr(organisation.acronym, title: organisation.name)
    elsif needs_definite_article?(organisation.name)
      "The #{organisation.name}"
    else
      organisation.name
    end
  end

  def organisation_display_name_without_definite_article(organisation)
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

  def organisation_with_parental_and_child_relationships_sentence(organisation)
    parental_relationship_sentence = organisation_display_name_with_parental_relationship_sentence(organisation)
    child_relationships_sentence(parental_relationship_sentence, organisation).html_safe
  end

  def organisation_display_name_with_parental_relationship_sentence(organisation)
    organisation_type_key = organisation.organisation_type_key
    parent_organisations = organisation.parent_organisations
    localised_organisation_type_with_fallback = I18n.t("organisation.type.#{organisation_type_key}", default: organisation_type_name(organisation))

    # org_type_with_no_indefinite_article is only used for Welsh, and it should be provided with a capital letter in the locale file.
    # display_name_without_article is also only used for Welsh. The locale file always inserts the article.
    locale_template_args = {
      display_name: ERB::Util.h(organisation_display_name_with_definite_article(organisation)).strip,
      display_name_without_article: ERB::Util.h(organisation_display_name_without_definite_article(organisation)).strip,
      org_type_with_no_indefinite_article: ERB::Util.h(localised_organisation_type_with_fallback),
      org_type: ERB::Util.h(add_indefinite_article(localised_organisation_type_with_fallback)),
      parents: parents_sentence(organisation_type_key, parent_organisations),
    }.compact

    locale_key = display_name_and_parental_relationship_i18n_key(organisation_type_key, parent_organisations)
    I18n.t(locale_key, **locale_template_args).html_safe
  end

  def display_name_and_parental_relationship_i18n_key(organisation_type_key, parent_organisations)
    return "organisation.display_name_and_parental_relationship.display_name_html" if organisation_type_key == :other && parent_organisations.empty?
    return "organisation.display_name_and_parental_relationship.is_organisation_type_html" unless display_parent_relationships?(organisation_type_key, parent_organisations)

    case organisation_type_key
    when :other
      "organisation.display_name_and_parental_relationship.works_with_html"
    when :sub_organisation
      "organisation.display_name_and_parental_relationship.part_of_html"
    when *SPONSORED_ORGANISATION_TYPE_KEYS
      "organisation.display_name_and_parental_relationship.sponsored_html"
    else
      "organisation.display_name_and_parental_relationship.default_with_parents_html"
    end
  end

  def display_parent_relationships?(organisation_type_key, parent_organisations)
    parent_organisations.any? && ORGANISATIONS_WITH_NO_PARENT_RELATIONSHIP_TYPE_KEYS.exclude?(organisation_type_key)
  end

  def parents_sentence(organisation_type_key, parent_organisations)
    return unless display_parent_relationships?(organisation_type_key, parent_organisations)

    parent_organisations.map { |parent| organisation_relationship_html(parent) }.to_sentence
  end

  def child_relationships_sentence(temp_org_sentence, organisation)
    supporting_bodies = organisation.supporting_bodies

    if supporting_bodies.any?
      temp_org_sentence.chomp!(".")
      temp_org_sentence += supporting_organisation_text(organisation)

      child_relationships_link_text = supporting_bodies.size.to_s
      child_relationships_link_text += supporting_bodies.size == 1 ? " #{I18n.t('organisation.child_relationships.public_body')}" : " #{I18n.t('organisation.child_relationships.agencies_and_public_bodies')}"

      temp_org_sentence += link_to(child_relationships_link_text, organisation.link_to_section_on_organisation_list_page, class: "brand__color")

      temp_org_sentence += "."
    end

    temp_org_sentence
  end

  def supporting_organisation_text(organisation)
    return ", #{I18n.t('organisation.child_relationships.supported_by')} " if organisation_type_name(organisation) != "other"
    return " #{I18n.t('organisation.child_relationships.and_is_supported_by')} " if organisation.parent_organisations.any?

    " #{I18n.t('organisation.child_relationships.is_supported_by')} "
  end

  def organisation_relationship_html(organisation)
    org_name = organisation.name.strip
    prefix = needs_definite_article?(org_name) ? "#{definite_article_for(org_name)} " : ""
    (prefix + link_to(org_name, organisation.public_path, class: "brand__color"))
  end

  # Returns the correct definite article for the given phrase in the current locale.
  # In Welsh: "yr" before vowels (a, e, i, o, u, w, y) and "h"; "y" before consonants.
  # In English: "the".
  def definite_article_for(org_name, capitalised: false)
    article = if I18n.locale == :cy
                welsh_definite_article(org_name)
              else
                "the"
              end

    capitalised ? article.upcase : article
  end

  def welsh_definite_article(phrase)
    phrase.strip[0].to_s =~ /\A[aeiouwyh]/i ? "yr" : "y"
  end

  def needs_definite_article?(phrase)
    !has_definite_article?(phrase) && PATTERNS_EXEMPT_FROM_DEFINITIVE_ARTICLE.none? { |e| e =~ phrase.downcase }
  end

  # Checks whether the phrase already begins with a definite article.
  # Handles both English ("the") and Welsh ("y", "yr").
  def has_definite_article?(phrase)
    downcased = phrase.downcase.strip
    downcased.start_with?("the ") || downcased.start_with?("yr ") || downcased.start_with?("y ")
  end
end
