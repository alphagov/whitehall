class Admin::SupportingPagesController < Admin::EditionsController
  before_filter :forbid_access_to_non_admins!, except: [:index, :show]

private

  def edition_class
    SupportingPage
  end

  def document_can_be_previously_published
    false
  end

  def forbid_access_to_non_admins!
    unless can?(:modify, SupportingPage)
      redirect_to admin_supporting_page_path(@edition),
        alert: "Policies are no longer changed via Whitehall, please see the Policies Publisher"
    end
  end
end
