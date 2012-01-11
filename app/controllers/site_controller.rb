class SiteController < ApplicationController
  def index
    last_modified = Document.latest_published_at.utc

    if stale?(last_modified: last_modified, public: true)
      @recently_updated = Document.published.by_published_at.limit(10)
    end
  end

  def sha
    skip_slimmer
    render text: `git rev-parse HEAD`
  end

  def headers
    @headers = request.headers.select {|k,v| k.starts_with?("HTTP_") }
  end
end