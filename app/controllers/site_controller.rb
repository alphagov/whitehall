class SiteController < PublicFacingController
  def sha
    skip_slimmer
    render text: Whitehall::CURRENT_SHA
  end
end
