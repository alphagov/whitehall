class Admin::LandingPagesController < Admin::EditionsController
private

  def edition_class
    LandingPage
  end
end
