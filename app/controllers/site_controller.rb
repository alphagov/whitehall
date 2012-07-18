class SiteController < PublicFacingController
  def grid
  end

  def sha
    skip_slimmer
    render text: `git rev-parse HEAD`
  end
end
