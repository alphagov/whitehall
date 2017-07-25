module LocalisedUrlPathHelper
  def self.included(klass)
    routes = Rails.application.routes.routes
    localised = routes.select { |r| r.parts.include?(:locale) }
    names = localised.map(&:name).compact

    # Override *_path and *_url methods for routes that take a locale param.
    names.each do |name|
      klass.send(:define_method, "#{name}_path", -> (*args) { super(*localise(args)) })
      klass.send(:define_method, "#{name}_url", -> (*args) { super(*localise(args)) })
    end
  end

  # Set the locale based on the current locale serving the request. We don't do
  # this if the provided object isn't available in that locale or if the locale
  # is English (the default).
  def localise(args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    object = args.last.respond_to?(:available_in_locale?) ? args.pop : nil
    options[:locale] ||= (defined?(params) && params[:locale] || I18n.locale)
    if (options[:locale].to_s == "en") || (object && !object.available_in_locale?(options[:locale]))
      options.delete(:locale)
    end
    args.push(object) if object
    args.push(options)
    args
  end
end
