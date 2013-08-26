class Admin::DocumentSeriesGroupsController < Admin::BaseController
  before_filter :load_document_series

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

  private
  def load_document_series
    @series = DocumentSeries.find(params[:document_series_id])
  end
end
