module LocalisedUrlPathHelper
  all_routes = Rails.application.routes.routes
  localised_routes = all_routes.select { |r| r.defaults.keys.include?(:locale) }

  localised_routes.map(&:name).each do |type|
    define_method(:"#{type}_path") do |*args|
      options = args.last.is_a?(Hash) ? args.pop : {}
      object = args.last.respond_to?(:available_in_locale?) ? args.pop : nil
      options[:locale] ||= (params[:locale] || I18n.locale)
      if (options[:locale].to_s == "en") || (object && !object.available_in_locale?(options[:locale]))
        options.delete(:locale)
      end
      args.push(object) if object
      args.push(options)
      super(*args)
    end
  end
end
