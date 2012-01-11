class PublicFacingController < ApplicationController
  before_filter :set_cache_control_headers

  private

  def set_cache_control_headers
    expires_in 30.seconds, public: true
  end
end