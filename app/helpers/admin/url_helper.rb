module Admin::UrlHelper
  def website_home_url
    if host = Whitehall.public_host_for(request.host)
      "http://#{host}/government"
    else
      root_path
    end
  end
end