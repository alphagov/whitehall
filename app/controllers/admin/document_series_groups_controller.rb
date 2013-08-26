class Admin::DocumentSeriesGroupsController < Admin::BaseController
  before_filter :load_document_series
  before_filter :load_document_series_group, only: [:edit, :update]

  def new
    @group = @series.groups.build
  end

  def create
    @group = @series.groups.build(params[:document_series_group])
    if @group.save
      redirect_to admin_document_series_documents_path(@series),
                  notice: "'#{@group.heading}' added"
    else
      render :new
    end
  end

  def update
    @group.update_attributes!(params[:document_series_group])
    redirect_to admin_document_series_documents_path(@series),
                notice: "'#{@group.heading}' saved"
  rescue ActiveRecord::RecordInvalid
    render :edit
  end

  private
  def load_document_series
    @series = DocumentSeries.find(params[:document_series_id])
  end

  def load_document_series_group
    @group = @series.groups.find(params[:id])
  end
end
