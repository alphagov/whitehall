class PublicFacingController < ApplicationController
  helper :all

  before_action :set_cache_control_headers
  before_action :restrict_request_formats
  before_action :set_x_frame_options

  around_action :set_locale

  rescue_from GdsApi::TimedOutException do |exception|
    log_error_and_render_500 exception
  end

  rescue_from GdsApi::HTTPErrorResponse do |exception|
    if exception.code == 502
      log_error_and_render_500 exception
    else
      raise
    end
  end

  # Allows additional request formats to be enabled.
  #
  # By default, PublicFacingController actions will only respond to HTML requests. To enable
  # additional formats on any given action, use this helper method. For example:
  #
  #   enable_request_formats index: [:atom, :json]
  #
  # That would allow both atom and JSON requests for the :index action to be processed.
  #
  def self.enable_request_formats(options)
    options.each do |action, formats|
      self.acceptable_formats[action.to_sym] ||= Set.new
      self.acceptable_formats[action.to_sym] += Array(formats)
    end
  end

  def self.acceptable_formats
    @acceptable_formats ||= {}
  end

  def render_not_found
    render plain: "Not found", status: :not_found
  end

  private

  def log_error_and_render_500(exception)
    logger.error "\n#{exception.class} (#{exception.message}):\n#{exception.backtrace.join("\n")}\n\n"
    render plain: 'API Timed Out', status: :internal_server_error
  end

  def set_locale(&block)
    I18n.with_locale(params[:locale] || I18n.default_locale, &block)
  end

  def set_cache_control_headers
    expires_in Whitehall.default_cache_max_age, public: true
  end

  def restrict_request_formats
    unless can_handle_format?(request.format)
      render status: :not_acceptable, plain: "Request format #{request.format} not handled."
    end
  end

  def can_handle_format?(format)
    return true if format == Mime[:html]
    format && self.class.acceptable_formats.fetch(params[:action].to_sym, []).include?(format.to_sym)
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

  def latest_presenters(editions, params = {})
    options = { translated: false, reverse: true, count: 3 }.merge(params)
    latest = editions.includes(:translations, :document)
    latest = latest.with_translations(I18n.locale) if options[:translated]
    latest = latest.in_reverse_chronological_order if options[:reverse]
    latest = latest.limit(options[:count]) if options[:count]
    latest.empty? ? [] : decorate_collection(latest, latest.first.presenter)
  end

  def load_reshuffle_setting
    SitewideSetting.find_by(key: :minister_reshuffle_mode)
  end

  def set_x_frame_options
    response.headers['X-Frame-Options'] = 'ALLOWALL'
  end
end
