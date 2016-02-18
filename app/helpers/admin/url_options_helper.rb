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
end
