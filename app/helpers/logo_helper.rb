module LogoHelper
  def logo_classes(options = {})
    logo_class = ['organisation-logo']
    logo_class << 'stacked' if options[:stacked]
    if options[:use_identity] == false
      logo_class << 'no-identity'
    else
      class_name = options[:class_name] || options.fetch(:organisation).organisation_logo_type.class_name
      logo_class << class_name
    end
    logo_class = logo_class.join('-')

    classes = ['organisation-logo']
    classes << logo_class
    classes << "#{logo_class}-#{options[:size]}" if options[:size]
    classes.join(" ")
  end

  def organisation_logo(organisation, options = {})
    logo = if organisation.logo?
      image_tag(organisation.logo.url, alt: organisation.name, class: 'organisation-logo-custom')
    else
      organisation_logo_name(organisation)
    end
    linked_logo = link_to_if(options[:linked], logo, organisation_path(organisation))
    if organisation.logo?
      linked_logo
    else
      css_classes = logo_classes(organisation: organisation, size: options[:size], stacked: true)
      content_tag(:span, class: css_classes) { linked_logo }
    end
  end
end
