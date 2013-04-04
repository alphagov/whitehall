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
    type_name = ActiveSupport::Inflector.singularize(organisation.organisation_type.name.downcase)
  end

  def organisation_display_name_and_parental_relationship(organisation)
    name = ERB::Util.h(organisation_display_name(organisation))
    type_name = organisation_type_name(organisation)
    relationship = ERB::Util.h(add_indefinite_article(type_name))
    parents = organisation.parent_organisations.map {|parent| organisation_relationship_html(parent) }
    if parents.any?
      if type_name == 'other'
        "%s works with %s" % [name, parents.to_sentence]
      else
        "%s is %s of %s" % ([name, relationship, parents.to_sentence])
      end
    else
      "%s is %s" % [name, relationship]
    end.html_safe
  end

  def organisation_relationship_html(organisation)
    prefix = needs_definite_article?(organisation.name) ? "the " : ""
    (prefix + link_to(organisation.name, organisation_path(organisation)))
  end

  def needs_definite_article?(phrase)
    exceptions = [/^hm/, /ordnance survey/]
    !has_definite_article?(phrase) && !(exceptions.any? {|e| e =~ phrase.downcase})
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

  def organisation_wrapper(organisation, options = {}, &block)
    classes = [organisation.slug]
    classes << organisation.organisation_type.name.parameterize if organisation.respond_to?(:organisation_type)
    if organisation.organisation_type.sub_organisation?
      classes << organisation.parent_organisations.map(&:slug)
    end
    content_tag_for :div, organisation, class: classes.join(" ") do
      block.call
    end
  end

  def organisation_site_thumbnail_path(organisation)
    begin
      image_path("organisation_screenshots/#{organisation.slug}.png")
    rescue Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError
      image_path("thumbnail-placeholder.png")
    end
  end

  def has_any_transparency_pages?(organisation)
    @organisation.corporate_information_pages.any? ||
      @organisation.has_published_publications_of_type?(PublicationType::FoiRelease) ||
      @organisation.has_published_publications_of_type?(PublicationType::TransparencyData)
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
      @traffic_commissioners.any?
  end

  def organisations_grouped_by_type(organisations)
    organisations.group_by(&:organisation_type).sort_by { |type,department| type.listing_order }
  end

  def extra_board_member_class(organisation, i)
    clear_number = 3
    if organisation.important_board_members > 1
      clear_number = 4
    end
    (i % clear_number == 0) ? 'clear-person' : ''
  end

  def render_featured_topics_and_policies_list(featured_topics_and_policies_list)
    if featured_topics_and_policies_list.present?
      items = featured_topics_and_policies_list.featured_items.current
      links = items.map { |featured_item| link_to_featured_item featured_item }.compact
      if links.any?
        content_tag(:ul, class: 'featured-items') do
          links.map { |featured_item_link| content_tag(:li, featured_item_link.html_safe) }.join.html_safe
        end
      end
    end
  end

  def link_to_all_featured_policies(organisation)
    list = organisation.featured_topics_and_policies_list
    url =
      if list.nil? || list.link_to_filtered_policies?
        policies_path(departments: [organisation])
      else
        policies_path
      end
    link_to 'See all our policies', url
  end

  def link_to_featured_item(featured_item)
    case featured_item.item
    when Topic
      link_to featured_item.item.name, featured_item.item
    when Document
      edition = featured_item.item.published_edition
      if edition
        link_to edition.title, edition
      end
    end
  end
end
