class Admin::EditionSlugController < Admin::BaseController
  before_action :find_edition
  before_action :find_document
  before_action :find_published_edition
  before_action :enforce_permissions!

  def edit_slug; end

  def update_slug
    if reslugger_class.new(@document, @published_edition, current_user, params.dig("document", "slug")).run!
      flash[:notice] = "Slug updated successfully"
      redirect_to admin_edition_path(@published_edition)
    else
      render :edit_slug
    end
  end

private

  def reslugger_class
    return DataHygiene::LandingPageRepather if @document.document_type == "LandingPage"

    DataHygiene::DocumentReslugger
  end

  def find_edition
    @edition = Edition.find(params[:id])
  end

  def find_document
    @document = @edition.document
  end

  def find_published_edition
    @published_edition = @document.editions.published.last
  end

  def enforce_permissions!
    enforce_permission!(:perform_administrative_tasks, @edition)
  end
end
