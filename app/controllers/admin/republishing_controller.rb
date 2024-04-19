class Admin::RepublishingController < Admin::BaseController
  before_action :enforce_permissions!

  def index
    @republishable_pages = republishable_pages
  end

  def confirm_page
    page_to_republish = republishable_pages.find { |page| page[:slug] == params[:page_slug] }

    return render "admin/errors/not_found", status: :not_found unless page_to_republish

    @title = page_to_republish[:title]
    @republishing_path = admin_republishing_page_republish_path(page_to_republish[:slug])
  end

  def republish_page
    page_to_republish = republishable_pages.find { |page| page[:slug] == params[:page_slug] }

    return render "admin/errors/not_found", status: :not_found unless page_to_republish

    PresentPageToPublishingApiWorker.perform_async(page_to_republish[:presenter])
    flash[:notice] = "The '#{page_to_republish[:title]}' page has been scheduled for republishing"
    redirect_to(admin_republishing_index_path)
  end

  def find_organisation; end

  def search_organisation
    @organisation = Organisation.find_by(slug: params[:organisation_slug])

    unless @organisation
      flash[:alert] = "Organisation with slug '#{params[:organisation_slug]}' not found"
      return redirect_to(admin_republishing_organisation_find_path)
    end

    redirect_to(admin_republishing_organisation_confirm_path(params[:organisation_slug]))
  end

  def confirm_organisation
    unless @organisation&.slug == params[:organisation_slug]
      @organisation = Organisation.find_by(slug: params[:organisation_slug])
      render "admin/errors/not_found", status: :not_found unless @organisation
    end
  end

  def republish_organisation
    unless @organisation&.slug == params[:organisation_slug]
      @organisation = Organisation.find_by(slug: params[:organisation_slug])
      return render "admin/errors/not_found", status: :not_found unless @organisation
    end

    @organisation.publish_to_publishing_api
    flash[:notice] = "The '#{@organisation.name}' organisation has been scheduled for republishing"
    redirect_to(admin_republishing_index_path)
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
