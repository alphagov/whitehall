class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # TODO: remove default for locale
  def append_url_options(path, locale = :en, options = {})
    locale = normalise_locale(locale)

    if options[:format] && locale != I18n.default_locale
      path = "#{path}.#{locale}.#{options[:format]}"
    elsif locale != I18n.default_locale
      path = "#{path}.#{locale}"
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
