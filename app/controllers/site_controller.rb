class SiteController < ApplicationController
  def sha
    skip_slimmer
    render text: `git rev-parse HEAD`
  end

  def headers
    @headers = request.headers.select {|k,v| k.starts_with?("HTTP_") }
  end
end