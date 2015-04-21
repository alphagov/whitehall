class Admin::SupportingPagesController < Admin::EditionsController
  before_filter :forbid_access!, except: [:index, :show]

private

  def edition_class
    SupportingPage
  end

  def document_can_be_previously_published
    false
  end

  def forbid_access!
    redirect_to admin_supporting_page_path(@edition),
      alert: "Policies are no longer changed via Whitehall, please see the Policies Publisher"
  end
end
