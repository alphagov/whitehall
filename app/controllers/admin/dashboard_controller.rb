class Admin::DashboardController < Admin::BaseController

  def index
    if current_user.organisation
      @draft_documents = Edition.authored_by(current_user).where(state: 'draft').includes(:translations, :versions).in_reverse_chronological_order
      @force_published_documents = current_user.organisation.editions.force_published.includes(:translations, :versions).in_reverse_chronological_order.limit(20)
    end
  end
end
