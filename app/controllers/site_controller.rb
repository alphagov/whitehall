class SiteController < PublicFacingController
  def index
    @recently_updated = Document.published.by_published_at.limit(10)
  end

  def grid

  end

  def sha
    skip_slimmer
    render text: `git rev-parse HEAD`
  end

  def headers
    @headers = request.headers.select {|k,v| k.starts_with?("HTTP_") }
  end
end