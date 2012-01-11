module Admin::UrlHelper
  def website_home_url
    if host = Whitehall.public_host
      "http://#{host}/government"
    else
      root_path
    end
  end
end