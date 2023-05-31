class Admin::DashboardController < Admin::BaseController
  layout "design_system"

  def index
    if current_user.organisation
      @draft_documents = Edition.authored_by(current_user).where(state: "draft").includes(:translations, :versions).in_reverse_chronological_order.reject do |edition|
        edition.respond_to?(:owning_organisation) && edition.owning_organisation.nil?
      end

      @force_published_documents = current_user.organisation.editions.force_published.includes(:translations, :versions).in_reverse_chronological_order.limit(5).reject do |edition|
        edition.respond_to?(:owning_organisation) && edition.owning_organisation.nil?
      end
    end
  end
end
