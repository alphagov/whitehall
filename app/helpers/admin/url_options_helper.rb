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
    send("#{model.class.to_s.underscore}_url", model, options)
  end

  def view_on_website_link_for(model, options = {})
    url_options = options.delete(:url) || {}
    link_to "View on website", show_url_with_public_and_cachebusted_options(model, url_options), options
  end
end
