class Admin::RepublishingController < Admin::BaseController
  before_action :enforce_permissions!

  def index
    @republishable_pages = republishable_pages
  end

  def republish_page
    page_to_republish = republishable_pages.find { |page| page[:slug] == params[:page_slug] }

    return render "admin/errors/not_found", status: :not_found unless page_to_republish

    PresentPageToPublishingApiWorker.perform_async(page_to_republish[:presenter])
    flash[:notice] = "'#{page_to_republish[:title]}' page has been scheduled for republishing"
    redirect_to(admin_republishing_index_path)
  end

  def confirm_page
    page_to_republish = republishable_pages.find { |page| page[:slug] == params[:page_slug] }

    return render "admin/errors/not_found", status: :not_found unless page_to_republish

    @title = page_to_republish[:title]
    @republishing_path = admin_republishing_page_republish_path(page_to_republish[:slug])
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
      slug: historical_accounts_index_presenter.base_path.split("/").last,
      presenter: "PublishingApi::HistoricalAccountsIndexPresenter",
    }]
  end
end
