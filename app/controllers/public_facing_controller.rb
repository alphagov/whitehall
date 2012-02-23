class PublicFacingController < ApplicationController
  helper :all
  before_filter :set_cache_control_headers

  private

  def set_cache_control_headers
    expires_in 2.minutes, public: true
  end
end