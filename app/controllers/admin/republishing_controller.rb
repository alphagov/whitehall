class Admin::RepublishingController < Admin::BaseController
  before_action :enforce_permissions!

  def index
    @republishable_documents = republishable_documents
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
    }]
  end
end
