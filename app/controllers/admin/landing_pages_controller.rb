class Admin::LandingPagesController < Admin::EditionsController
  before_action :enforce_edition_permissions!

private

  def edition_class
    LandingPage
  end

  def enforce_edition_permissions!
    enforce_permission!(:update, @edition)
  end
end
