class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def append_url_options(path, options = {})
    locale = normalise_locale(options[:locale])

    if options[:format] && options[:locale] && locale != I18n.default_locale
      path = "#{path}.#{options[:locale]}.#{options[:format]}"
    elsif options[:locale] && locale != I18n.default_locale
      path = "#{path}.#{options[:locale]}"
    elsif options[:format]
      path = "#{path}.#{options[:format]}"
    end

    permitted_query_params = %i[
      cachebust
      preview
      token
      utm_campaign
      utm_medium
      utm_source
    ]

    query_params = options.slice(*permitted_query_params).compact

    path = "#{path}?#{query_params.to_query}" unless query_params.empty?

    path = "#{path}##{options[:anchor]}" if options[:anchor]

    path
  end

private

  def normalise_locale(locale)
    case locale
    when Struct
      locale.code
    when String
      locale.to_sym
    when Symbol
      locale
    end
  end
end
