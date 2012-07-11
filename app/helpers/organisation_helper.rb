module OrganisationHelper
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
    name = organisation_name_with_acronym(organisation)
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

  def organisation_navigation_link_to(body, path)
    if (current_organisation_navigation_path(params) == path) ||
       (params[:action] == "management_team" && path == current_organisation_navigation_path(params.merge(action: "about")))
      css_class = 'current'
    else
      css_class = nil
    end

    link_to body, path, class: css_class
  end

  def current_organisation_navigation_path(params)
    url_for params.slice(:controller, :action, :id).merge(only_path: true)
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
    classes = [
      organisation.slug,
      organisation_type_class(organisation.organisation_type),
      (organisation.active? ? 'active_organisation' : 'inactive_organisation'),
      options[:class]
    ]
    classes.compact.join(" ").strip
  end

  def social_media_account_link(account)
    title = "Connect with #{account.organisation.display_name} on #{account.service_name}"
    link_to account.url, title: title do
      concat image_tag "icons/16/#{account.service_name.downcase}.png", alt: account.service_name
      concat account.service_name
    end
  end

  def list_of_external_links_to_organisations(organisations)
    organisations.map do |o|
      o.url.present? ? link_to(o.logo_formatted_name, o.url) : o.logo_formatted_name
    end.to_sentence.html_safe
  end
end
