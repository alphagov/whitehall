module LogoHelper
  def logo_classes(options = {})
    logo_class = %w[organisation-logo]
    logo_class << "stacked" if options[:stacked]
    if options[:use_identity] == false
      logo_class << "no-identity"
    else
      class_name = options[:class_name] || options.fetch(:organisation).organisation_logo_type.class_name
      logo_class << class_name
    end
    logo_class = logo_class.join("-")

    classes = %w[organisation-logo]
    classes << logo_class
    classes << "#{logo_class}-#{options[:size]}" if options[:size]
    classes.join(" ")
  end

  def organisation_logo(organisation, options = {})
    logo = if organisation.custom_logo_selected?
             image_tag(organisation.logo.url, alt: organisation.name, class: "organisation-logo-custom")
           else
             organisation_logo_name(organisation)
           end
    linked_logo = link_to_if(options[:linked], logo, organisation.public_path)
    if organisation.custom_logo_selected?
      linked_logo
    else
      css_classes = logo_classes(organisation:, size: options[:size], stacked: true)
      tag.span(class: css_classes) { tag.span { linked_logo } }
    end
  end

  def translated_organisation_logo_name(organisation)
    if I18n.locale == "en"
      format_with_html_line_breaks(ERB::Util.html_escape(organisation.logo_formatted_name))
    else
      organisation.name
    end
  end
end
