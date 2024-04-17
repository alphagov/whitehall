class Admin::RepublishingController < Admin::BaseController
  before_action :enforce_permissions!

  def index
    @republishable_pages = republishable_pages
  end

  def republish_past_prime_ministers_index
    PresentPageToPublishingApiWorker.perform_async("PublishingApi::HistoricalAccountsIndexPresenter")
    flash[:notice] = "'Past Prime Ministers' page has been scheduled for republishing"
    redirect_to(admin_republishing_index_path)
  end

  def confirm_page
    page_to_republish = republishable_pages.find { |page| page[:slug] == params[:page_slug] }

    return render "admin/errors/not_found", status: :not_found unless page_to_republish

    @title = page_to_republish[:title]
    @republishing_path = page_to_republish[:republishing_path]
  end

private

  def enforce_permissions!
    enforce_permission!(:administer, :republish_content)
  end

  def republishable_pages
    historical_accounts_index_presenter = PublishingApi::HistoricalAccountsIndexPresenter.new

    [{
      title: historical_accounts_index_presenter.content[:title],
      public_path: historical_accounts_index_presenter.base_path,
      republishing_path: admin_republishing_republish_past_prime_ministers_path,
      slug: historical_accounts_index_presenter.base_path.split("/").last,
    }]
  end
end
