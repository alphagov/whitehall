class SiteController < PublicFacingController
  def sha
    skip_slimmer
    render text: Whitehall::CURRENT_RELEASE_SHA
  end
end
