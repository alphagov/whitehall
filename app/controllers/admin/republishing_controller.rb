class Admin::RepublishingController < Admin::BaseController
  before_action :enforce_permissions!

  def index
    @republishable_documents = republishable_documents
  end

  def republish_past_prime_ministers_index
    PresentPageToPublishingApiWorker.perform_async("PublishingApi::HistoricalAccountsIndexPresenter")
    flash[:notice] = "'Past Prime Ministers' page has been scheduled for republishing"
    redirect_to(admin_republishing_index_path)
  end

  def confirm
    republishable_document = republishable_documents.find { |document| document[:slug] == params[:document_slug] }

    return render "admin/errors/not_found", status: :not_found unless republishable_document

    @document_title = republishable_document[:title]
    @republishing_path = republishable_document[:republishing_path]
  end

private

  def enforce_permissions!
    enforce_permission!(:administer, :republish_documents)
  end

  def republishable_documents
    historical_accounts_index_presenter = PublishingApi::HistoricalAccountsIndexPresenter.new

    [{
      title: historical_accounts_index_presenter.content[:title],
      public_path: historical_accounts_index_presenter.base_path,
      republishing_path: admin_republishing_republish_past_prime_ministers_path,
      slug: historical_accounts_index_presenter.base_path.split("/").last,
    }]
  end
end
