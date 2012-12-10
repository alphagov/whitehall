module OrganisationHelper
  def organisation_display_name(organisation)
    if organisation.acronym.present?
      content_tag(:abbr, organisation.acronym, title: organisation.name)
    else
      organisation.name
    end
  end

  def organisation_type_name(organisation)
    type_name = ActiveSupport::Inflector.singularize(organisation.organisation_type.name.downcase)
    type_name == 'other' ? 'body' : type_name
  end

  def organisation_display_name_and_parental_relationship(organisation)
    name = organisation_display_name(organisation)
    relationship = add_indefinite_article(organisation_type_name(organisation))
    parent = organisation.parent_organisations.first
    params = [ERB::Util.h(name), ERB::Util.h(relationship)]
    if parent
      prefix = needs_definite_article?(parent.name) ? "the " : ""
      params << prefix + link_to(parent.name, organisation_path(parent))
      "%s is %s of %s" % params
    else
      "%s is %s" % params
    end.html_safe
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
    classes = [organisation.slug, organisation.organisation_type.name.parameterize]
    content_tag_for :div, organisation, class: classes.join(" ") do
      block.call
    end
  end

  def organisation_logo_classes(organisation, options={})
    logo_class = [ 'organisation-logo' ]
    logo_class << 'stacked' if options[:stacked]
    if options[:use_identity] == false
      logo_class << 'no-identity'
    else
      logo_class << organisation.organisation_logo_type.class_name
    end
    logo_class = logo_class.join('-')

    classes = [ 'organisation-logo' ]
    classes << logo_class
    classes << "#{logo_class}-#{options[:size]}" if options[:size]
    classes.join(" ")
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
      @civil_servants.any? ||
      @organisation.military_roles.any? ||
      @traffic_commissioner_roles.any?
  end
end
