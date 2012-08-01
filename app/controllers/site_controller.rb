class SiteController < PublicFacingController
  def sha
    skip_slimmer
    render text: `git rev-parse HEAD`
  end
end
