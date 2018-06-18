module OrganisationHelper
  def organisation_display_name(organisation)
    if organisation.acronym.present?
      content_tag(:abbr, organisation.acronym, title: organisation.name)
    else
      organisation.name
    end
  end

  def organisation_logo_name(organisation, stacked = true)
    if stacked
      format_with_html_line_breaks(ERB::Util.html_escape(organisation.logo_formatted_name))
    else
      organisation.name
    end
  end

  def organisation_type_name(organisation)
    ActiveSupport::Inflector.singularize(organisation.organisation_type.name.downcase)
  end

  def organisation_govuk_status_description(organisation)
    if organisation.closed?
      organisation_closed_govuk_status_description(organisation)
    elsif organisation.transitioning?
      "#{organisation.name} is in the process of joining GOV.UK. In the meantime, #{link_to(organisation.url, organisation.url)} remains the official source.".html_safe
    elsif organisation.joining?
      if organisation.url.present?
        "#{organisation.name} currently has a #{link_to('separate website', organisation.url)} but will soon be incorporated into GOV.UK".html_safe
      else
        "#{organisation.name} will soon be incorporated into GOV.UK"
      end
    elsif organisation.exempt?
      if organisation.url.present?
        "#{organisation.name} has a #{link_to('separate website', organisation.url)}".html_safe
      else
        "#{organisation.name} has no website"
      end
    end
  end

  def organisation_closed_govuk_status_description(organisation)
    if organisation.no_longer_exists?
      if organisation.closed_at.present?
        "#{organisation.name} closed in #{organisation.closed_at.to_s(:one_month_precision)}"
      else
        "#{organisation.name} has closed"
      end
    elsif organisation.replaced? || organisation.split?
      if organisation.closed_at.present?
        "#{organisation.name} was replaced by #{superseding_organisations_text(organisation)} in #{organisation.closed_at.to_s(:one_month_precision)}".html_safe
      else
        "#{organisation.name} was replaced by #{superseding_organisations_text(organisation)}".html_safe
      end
    elsif organisation.merged?
      if organisation.closed_at.present?
        "#{organisation.name} became part of #{superseding_organisations_text(organisation)} in #{organisation.closed_at.to_s(:one_month_precision)}".html_safe
      else
        "#{organisation.name} is now part of #{superseding_organisations_text(organisation)}".html_safe
      end
    elsif organisation.changed_name?
      "#{organisation.name} is now called #{superseding_organisations_text(organisation)}".html_safe
    elsif organisation.left_gov?
      "#{organisation.name} is now independent of the UK government"
    elsif organisation.devolved?
      if organisation.superseded_by_devolved_administration?
        "#{organisation.name} is a body of the #{superseding_organisations_text(organisation)}".html_safe
      else
        "#{organisation.name} is now run by the #{superseding_organisations_text(organisation)}".html_safe
      end
    end
  end

  def superseding_organisations_text(organisation)
    if organisation.superseding_organisations.any?
      organisation_links = organisation.superseding_organisations.map { |org|
        link_to(org.name, organisation_path(org))
      }
      organisation_links.to_sentence.html_safe
    end
  end

  def govuk_status_meta_data_for(organisation)
    if organisation.exempt?
      content_tag :span, "separate website", class: 'metadata'
    elsif organisation.joining? || organisation.transitioning?
      content_tag :span, "moving to GOV.UK", class: 'metadata'
    end
  end

  def organisation_display_name_and_parental_relationship(organisation)
    name = ERB::Util.h(organisation_display_name(organisation))
    type_name = organisation_type_name(organisation)
    relationship = ERB::Util.h(add_indefinite_article(type_name))
    parents = organisation.parent_organisations.map { |parent| organisation_relationship_html(parent) }

    description = if parents.any?
                    case type_name
                    when 'other'
                      "#{name} works with #{parents.to_sentence}."
                    when 'non-ministerial department'
                      "#{name} is #{relationship}."
                    when 'sub-organisation'
                      "#{name} is part of #{parents.to_sentence}."
                    when 'executive non-departmental public body', 'advisory non-departmental public body', 'tribunal non-departmental public body', 'executive agency'
                      "#{name} is #{relationship}, sponsored by #{parents.to_sentence}."
                    else
                      "#{name} is #{relationship} of #{parents.to_sentence}."
                    end
                  else
                    type_name != 'other' ? "#{name} is #{relationship}." : name.to_s
                  end

    description.html_safe
  end

  def organisation_display_name_including_parental_and_child_relationships(organisation)
    organisation_name = organisation_display_name_and_parental_relationship(organisation)
    child_organisations = organisation.supporting_bodies

    if child_organisations.any?
      organisation_name.chomp!('.')
      organisation_name += organisation_type_name(organisation) != 'other' ? ", supported by " : " is supported by "

      child_relationships_link_text = child_organisations.size.to_s
      child_relationships_link_text += child_organisations.size == 1 ? " public body" : " agencies and public bodies"

      organisation_name += link_to(child_relationships_link_text, organisations_path(anchor: organisation.slug), class: 'brand__color')
      organisation_name += "."
    end

    organisation_name.html_safe
  end

  def organisation_relationship_html(organisation)
    prefix = needs_definite_article?(organisation.name) ? "the " : ""
    (prefix + link_to(organisation.name, organisation_path(organisation), class: 'brand__color'))
  end

  def needs_definite_article?(phrase)
    exceptions = [/civil service resourcing/, /^hm/, /ordnance survey/]
    !has_definite_article?(phrase) && !(exceptions.any? { |e| e =~ phrase.downcase })
  end

  def has_definite_article?(phrase)
    phrase.downcase.strip[0..2] == 'the'
  end

  def add_indefinite_article(noun)
    indefinite_article = starts_with_vowel?(noun) ? 'an' : 'a'
    "#{indefinite_article} #{noun}"
  end

  def starts_with_vowel?(word_or_phrase)
    'aeiou'.include?(word_or_phrase.downcase[0])
  end

  def organisation_wrapper(organisation, _options = {})
    classes = [organisation.slug, organisation_brand_colour_class(organisation)]
    classes << organisation.organisation_type.name.parameterize if organisation.respond_to?(:organisation_type)
    content_tag_for :div, organisation, class: classes.join(" ") do
      yield
    end
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
    [organisation.slug, organisation.name, organisation.acronym].join(' ')
  end

  def people_to_show?
    @ministers.any? ||
      @special_representatives.any? ||
      @board_members.any? ||
      @important_board_members.any? ||
      @military_personnel.any? ||
      @chief_professional_officers.any? ||
      @traffic_commissioners.any? ||
      @judges.any?
  end

  def organisations_grouped_by_type(organisations)
    organisations.group_by(&:organisation_type).sort_by { |type, _department| type.listing_position }
  end

  def extra_board_member_class(organisation, i)
    clear_number = 3
    if organisation.important_board_members > 1
      clear_number = 4
    end
    (i % clear_number).zero? ? 'clear-person' : ''
  end

  def array_of_links_to_organisations(organisations)
    organisations.map do |organisation|
      link_to organisation.name, organisation, class: 'organisation-link'
    end
  end

  def organisation_count_paragraph(org_array)
    contents = content_tag(:span, org_array.length, class: 'count js-filter-count')
    content_tag(:p, contents.html_safe)
  end

  def show_corporate_information_pages?(organisation)
    organisation.live? && (!organisation.court_or_hmcts_tribunal? ||
      organisation.corporate_information_pages.published.reject { |cip| cip.slug == "about" }.any?)
  end
end
