module OrganisationHelper
  include ApplicationHelper

  PATTERNS_EXEMPT_FROM_DEFINITIVE_ARTICLE = [
    /civil service resourcing/,
    /^hm/,
    /ordnance survey/,
    /homes england/,
    /british wool/,
    /building law and hygiene/,
  ].freeze

  SPONSORED_TYPE_KEYS = %i[
    advisory_ndpb
    executive_agency
    executive_ndpb
    special_health_authority
  ].freeze

  IDENTIFICATION_ONLY_TYPE_KEYS = %i[
    non_ministerial_department
  ].freeze

  def organisation_relationship_display_name(organisation)
    if organisation.acronym.present?
      tag.abbr(organisation.acronym, title: organisation.name)
    elsif needs_definite_article?(organisation.name)
      "#{I18n.t('organisation.the').capitalize} #{organisation.name}"
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
    type_key = organisation.organisation_type_key
    parent_organisations = organisation.parent_organisations

    relationship_description(organisation, type_key, parent_organisations).html_safe
  end

  def relationship_description(organisation, type_key, parent_organisations)
    key = relationship_i18n_key(type_key, parent_organisations)
    args = relationship_template_args(organisation, type_key)
    args[:parents] = parents_sentence(parent_organisations) if display_parent_relationships?(type_key, parent_organisations)
    I18n.t(key, **args)
  end

  def relationship_i18n_key(type_key, parent_organisations)
    return "organisation.relationship.none_html" if type_key == :other && parent_organisations.empty?
    return "organisation.relationship.identification_html" unless display_parent_relationships?(type_key, parent_organisations)

    case type_key
    when :other then "organisation.relationship.works_with_html"
    when :sub_organisation then "organisation.relationship.part_of_html"
    when *SPONSORED_TYPE_KEYS then "organisation.relationship.sponsored_html"
    else "organisation.relationship.default_with_parents_html"
    end
  end

  def display_parent_relationships?(type_key, parent_organisations)
    parent_organisations.any? && IDENTIFICATION_ONLY_TYPE_KEYS.exclude?(type_key)
  end

  def relationship_template_args(organisation, type_key)
    localised_type_name = I18n.t("organisation.type.#{type_key}", default: organisation_type_name(organisation))
    {
      name: ERB::Util.h(organisation_relationship_display_name(organisation)).strip,
      type_name: ERB::Util.h(localised_type_name),
      relationship: ERB::Util.h(add_indefinite_article(localised_type_name)),
    }
  end

  def parents_sentence(parent_organisations)
    parent_organisations.map { |parent| organisation_relationship_html(parent) }.to_sentence
  end

  def organisation_display_name_including_parental_and_child_relationships(organisation)
    organisation_name = organisation_display_name_and_parental_relationship(organisation)
    child_organisations = organisation.supporting_bodies

    if child_organisations.any?
      organisation_name.chomp!(".")
      organisation_name += supporting_organisation_text(organisation)

      child_relationships_link_text = child_organisations.size.to_s
      child_relationships_link_text += child_organisations.size == 1 ? " public body" : " agencies and public bodies"

      organisation_name += link_to(child_relationships_link_text, organisation.link_to_section_on_organisation_list_page, class: "brand__color")

      organisation_name += "."
    end

    organisation_name.html_safe
  end

  def supporting_organisation_text(organisation)
    return ", supported by " if organisation_type_name(organisation) != "other"
    return " and is supported by " if organisation.parent_organisations.any?

    " is supported by "
  end

  def organisation_relationship_html(organisation)
    prefix = needs_definite_article?(organisation.name.strip) ? "#{I18n.t('organisation.the')} " : ""
    (prefix + link_to(organisation.name.strip, organisation.public_path, class: "brand__color"))
  end

  def needs_definite_article?(phrase)
    !has_definite_article?(phrase) && PATTERNS_EXEMPT_FROM_DEFINITIVE_ARTICLE.none? { |e| e =~ phrase.downcase }
  end

  def has_definite_article?(phrase)
    phrase.downcase.strip[0..2] == "the"
  end
end
