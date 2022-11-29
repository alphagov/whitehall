class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def append_url_options(path, options = {})
    if options[:format] && options[:locale]
      path = "#{path}.#{options[:locale]}.#{options[:format]}"
    elsif options[:locale] && options[:locale] != I18n.default_locale
      path = "#{path}.#{options[:locale]}"
    elsif options[:format]
      path = "#{path}.#{options[:format]}"
    end

    if options[:cachebust]
      query_params = {
        cachebust: options[:cachebust],
      }
      path = "#{path}?#{query_params.to_query}"
    end

    path = "#{path}##{options[:anchor]}" if options[:anchor]

    path
  end
end
