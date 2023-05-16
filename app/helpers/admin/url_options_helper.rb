module Admin::UrlOptionsHelper
  def public_url_options
    { host: Whitehall.public_host, protocol: Whitehall.public_protocol }
  end

  def cachebust_url_options
    { cachebust: Time.zone.now.getutc.to_i }
  end

  def public_and_cachebusted_url_options
    public_url_options.merge(cachebust_url_options)
  end

  def show_url_with_public_and_cachebusted_options(model, url_options = {})
    options = public_and_cachebusted_url_options.merge(url_options)
    if model.respond_to?(:public_url)
      model.public_url(options)
    else
      send("#{model.class.to_s.underscore}_url", model, options)
    end
  end

  def view_on_website_link_for(model, options = {})
    url_options = options.delete(:url) || {}
    link_to "View on website (opens in a new tab)", show_url_with_public_and_cachebusted_options(model, url_options), options
  end

  def auth_bypass_options(edition)
    {
      token: edition.auth_bypass_token,
      utm_source: :share,
      utm_medium: :preview,
      utm_campaign: :govuk_publishing,
    }
  end

  def show_url_with_auth_bypass_options(edition, options = {})
    edition.public_url(auth_bypass_options(edition).merge(options))
  end
end
