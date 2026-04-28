class Admin::PlanForChangeLandingPagesController < Admin::EditionsController
  before_action :enforce_edition_permissions!

private

  def edition_class
    PlanForChangeLandingPage
  end

  def enforce_edition_permissions!
    enforce_permission!(:update, @edition)
  end
end
