module LocalisedUrlPathHelper
  all_routes = Rails.application.routes.routes
  localised_routes = all_routes.select { |r| r.defaults.keys.include?(:locale) }

  localised_routes.map(&:name).each do |type|
    define_method(:"#{type}_path") do |*args|
      options = args.last.is_a?(Hash) ? args.pop : {}
      options[:locale] ||= params[:locale]
      options.delete(:locale) if options[:locale].to_s == "en"
      args.push(options)
      super(*args)
    end
  end
end
