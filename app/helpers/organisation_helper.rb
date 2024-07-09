module OrganisationHelper
  include ApplicationHelper

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

  def worldwide_organisation_logo_name(organisation)
    if I18n.locale == :en && organisation.logo_formatted_name.present?
      format_with_html_line_breaks(ERB::Util.html_escape(organisation.logo_formatted_name))
    else
      organisation.title
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
end
