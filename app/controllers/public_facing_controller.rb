class PublicFacingController < ApplicationController
  helper :all
  before_filter :set_cache_control_headers
  before_filter :set_search_path
  before_filter :deny_wap_requests

  private

  def set_cache_control_headers
    expires_in 2.minutes, public: true
  end

  def set_search_path
    response.headers[Slimmer::Headers::SEARCH_PATH_HEADER] = search_path
  end

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end

  def deny_wap_requests
    request.format.to_sym == :wap ? error(406) : return
  end
end
