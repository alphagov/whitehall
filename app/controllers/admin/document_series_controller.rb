class Admin::DocumentSeriesController < Admin::BaseController
  before_filter :find_organisation, except: [:index]
  before_filter :find_document_series, except: [:new, :create, :index]

  def new
    @document_series = @organisation.document_series.build
  end

  def create
    @document_series = @organisation.document_series.build(params[:document_series])
    @document_series.groups.build(DocumentSeriesGroup.default_attributes)
    if @document_series.save
      redirect_to admin_organisation_document_series_path(@organisation, @document_series)
    else
      render :new
    end
  end

  def index
    if current_user.organisation
      redirect_to admin_organisation_document_series_index_path(current_user.organisation)
    else
      redirect_to admin_organisations_path, notice: 'Choose an organisation to view all the document series belonging to it'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @document_series.update_attributes(params[:document_series])
      redirect_to admin_organisation_document_series_path(@organisation, @document_series)
    else
      render :edit
    end
  end

  def destroy
    @document_series.delete!
    if @document_series.deleted?
      redirect_to admin_organisation_document_series_index_path(@document_series.organisation), notice: "document series destroyed"
    else
      redirect_to admin_organisation_document_series_path(@document_series.organisation, @document_series),
                  alert: "Cannot destroy a document series with associated content. Please remove the associated documents first."
    end
  end

  private

  def find_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end

  def find_document_series
    @document_series = @organisation.document_series.find(params[:id])
  end
end
