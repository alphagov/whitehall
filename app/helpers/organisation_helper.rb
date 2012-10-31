module OrganisationHelper
  def organisation_branding_class(organisation)
    if organisation.use_single_identity_branding?
      "single-identity"
    end
  end

  def organisation_display_name(organisation)
    if organisation.acronym.present?
      content_tag(:abbr, organisation.acronym, title: organisation.name)
    else
      organisation.name
    end
  end

  def organisation_name_with_acronym(organisation)
    if organisation.acronym.present?
      "%s (%s)" % [organisation.name, organisation.acronym]
    else
      organisation.name
    end
  end

  def organisation_type_name(organisation)
    type_name = ActiveSupport::Inflector.singularize(organisation.organisation_type.name.downcase)
    type_name == 'other' ? 'public body' : type_name
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

  def organisation_view_all_tag(organisation, kind)
    path = send(:"#{kind}_organisation_path", @organisation)
    text = (kind == :announcements) ? "news & speeches" : kind
    content_tag(:span, safe_join(['View all', content_tag(:span, @organisation.name, class: "visuallyhidden"), link_to(text, path)], ' '), class: "view_all")
  end

  def organisation_wrapper(organisation, options = {}, &block)
    content_tag_for :div, organisation, class: organisation_logo_classes(organisation, options) do
      block.call
    end
  end

  def organisation_type_class(organisation_type)
    organisation_type.name.downcase.gsub(/\s/, '-') if organisation_type && organisation_type.name.present?
  end

  def organisation_logo_classes(organisation, options={})
    classes = []
    classes << organisation.slug
    classes << organisation_type_class(organisation.organisation_type)
    classes << organisation_branding_class(organisation) unless options[:no_single_identity]
    classes << options[:class] if options[:class]
    classes.compact.join(" ").strip
  end

  def organisation_site_thumbnail_path(organisation)
    begin
      image_path("organisation_screenshots/#{organisation.slug}.png")
    rescue ActionView::Template::Error
      image_path("thumbnail-placeholder.png")
    end
  end
end
