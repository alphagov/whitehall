class Admin::DocumentSourcesController < Admin::BaseController
  before_filter :find_edition

  def new
    @document_source = @edition.document.build_document_source
  end

  def create
    @document_source = @edition.document.create_document_source(params[:document_source])
    if !@document_source.persisted?
      render :new
    else
      redirect_to admin_edition_path(@edition, anchor: 'document-sources')
    end
  end

  private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end
end
