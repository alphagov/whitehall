class PublicFacingController < ApplicationController
  helper :all

  before_filter :set_cache_control_headers
  before_filter :set_search_index
  before_filter :restrict_request_formats

  around_filter :set_locale

  include LocalisedUrlPathHelper

  private

  def set_locale(&block)
    I18n.with_locale(params[:locale] || I18n.default_locale, &block)
  end

  def set_cache_control_headers
    expires_in Whitehall.default_cache_max_age, public: true
  end

  def set_search_index
    response.headers[Slimmer::Headers::SEARCH_INDEX_HEADER] = 'government'
  end

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end

  def restrict_request_formats
    allowed_formats = [Mime::HTML, Mime::JSON, Mime::XML, Mime::ATOM, Mime::ALL]
    error(404) unless allowed_formats.include?(request.format)
  end

  def set_expiry(duration = 30.minutes)
    unless Rails.env.development?
      expires_in(duration, public: true)
    end
  end

  def set_analytics_format
    set_slimmer_format_header(Whitehall.analytics_format(analytics_format))
  end

  def search_backend
    if Locale.current.english?
      Whitehall.search_backend
    else
      Whitehall::DocumentFilter::Mysql
    end
  end

  def decorate_collection(collection, presenter_class)
    Whitehall::Decorators::CollectionDecorator.new(collection, presenter_class, view_context)
  end
end
