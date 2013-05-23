class Admin::DocumentSeriesController < Admin::BaseController
  before_filter :find_organisation, except: [:index]
  before_filter :find_document_series, except: [:new, :create, :index]

  def new
    @document_series = @organisation.document_series.build
  end

  def create
    @document_series = @organisation.document_series.build(params[:document_series])
    if @document_series.save
      redirect_to admin_organisation_document_series_path(@organisation, @document_series)
    else
      render action: :new
    end
  end

  def index
    @document_series = DocumentSeries.with_translations_for(:organisation).order("organisation_translations.name, document_series.name")
  end

  def show
  end

  def edit
  end

  def update
    if @document_series.update_attributes(params[:document_series])
      redirect_to admin_organisation_document_series_path(@organisation, @document_series)
    else
      render action: :edit
    end
  end

  def destroy
    @document_series.delete!
    if @document_series.deleted?
      redirect_to admin_document_series_index_path, notice: "document series destroyed"
    else
      redirect_to admin_document_series_index_path,
                  alert: "Cannot destroy document series with associated content, please remove them first"
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
