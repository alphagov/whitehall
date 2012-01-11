module Admin::UrlHelper
  def website_home_url
    case request.host
    when "whitehall.preview.alphagov.co.uk"
      "http://www.preview.alphagov.co.uk/government"
    when "whitehall.production.alphagov.co.uk"
      "http://www.gov.uk/government"
    else
      root_path
    end
  end
end