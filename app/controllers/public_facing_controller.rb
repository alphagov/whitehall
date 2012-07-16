class PublicFacingController < ApplicationController
  helper :all
  before_filter :set_cache_control_headers
  before_filter :set_search_path

  private

  def set_cache_control_headers
    expires_in 2.minutes, public: true
  end

  def set_search_path
    response.headers[Slimmer::SEARCH_PATH_HEADER] = search_path
  end
end