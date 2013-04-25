module LogoHelper
  def logo_classes(options = {})
    logo_class = ['organisation-logo']
    logo_class << 'stacked' if options[:stacked]
    if options[:use_identity] == false
      logo_class << 'no-identity'
    else
      logo_class << options[:class_name]
    end
    logo_class = logo_class.join('-')

    classes = ['organisation-logo']
    classes << logo_class
    classes << "#{logo_class}-#{options[:size]}" if options[:size]
    classes.join(" ")
  end
end
