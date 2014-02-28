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
      if organisation.closed_at.present?
        "#{organisation.name} closed on #{absolute_date(organisation.closed_at, class: 'closed-at')}".html_safe
      else
        "#{organisation.name} has closed"
      end
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

  def superseding_organisations_paragraph_for(organisation)
    if organisation.superseding_organisations.any?
      organisation_links = organisation.superseding_organisations.map { |org|
        link_to(org.name, organisation_path(org))
      }
      content_tag :p, "#{t('organisation.superseding_organisation_text')} #{organisation_links.to_sentence}.".html_safe
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

  def organisation_wrapper(organisation, options = {}, &block)
    classes = [organisation.slug, organisation_brand_colour_class(organisation)]
    classes << organisation.organisation_type.name.parameterize if organisation.respond_to?(:organisation_type)
    content_tag_for :div, organisation, class: classes.join(" ") do
      block.call
    end
  end

  def organisation_brand_colour_class(organisation)
    if organisation.organisation_brand_colour
      "#{organisation.organisation_brand_colour.class_name}-brand-colour"
    else
      ""
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
      @traffic_commissioners.any?
  end

  def organisations_grouped_by_type(organisations)
    organisations.group_by(&:organisation_type).sort_by { |type, department| type.listing_position }
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
      items = featured_topics_and_policies_list.current_and_linkable_featured_items
      if items.any?
        content_tag(:ul, class: 'featured-items') do
          items.map do |featured_item|
            linkable_item = featured_item.linkable_item
            url =
              if linkable_item.is_a? Edition
                public_document_path(linkable_item)
              else
                linkable_item
              end
            content_tag(:li, link_to(featured_item.linkable_title, url))
          end.join.html_safe
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

  def organisations_link_array(lead_organisations, organisations, prefix = nil)
    all_organisations = []
    lead_organisations.map do |o|
      all_organisations << { organisation: o, lead: true }
    end
    (organisations - lead_organisations).map do |o|
      all_organisations << { organisation: o, lead: false }
    end

    all_organisations.map do |o|
      content_tag_for :span, o[:organisation], prefix, ({class: "lead"} if o[:lead]) do
        link_to o[:organisation].name, o[:organisation]
      end
    end
  end

  def organisations_link_sentence(lead_organisations, organisations)
    organisations_link_array(lead_organisations, organisations).to_sentence.html_safe
  end

  def organisation_count_paragraph(org_array, opts = {})
    opts = {with_live_on_govuk: true}.merge(opts)
    contents = content_tag(:span, org_array.length, class: 'count js-filter-count')

    if opts[:with_live_on_govuk]
      organisations_that_are_live = org_array.select { |org| org.live? }.length
      organisations_that_are_live = 'All' if organisations_that_are_live >= org_array.length

      contents += content_tag(:span, "#{organisations_that_are_live} live on GOV.UK", class: 'on-govuk')
    end

    content_tag(:p, contents.html_safe)
  end
end
