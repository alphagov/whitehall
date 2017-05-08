class Admin::DocumentSourcesController < Admin::BaseController
  before_action :require_import_permission!
  before_action :find_edition

  def update
    @document_sources = params[:document_sources]
    @edition.document.document_sources.destroy_all
    @document_sources.split(/\r?\n/).each do |source|
      @edition.document.document_sources.create(url: source)
    end

    redirect_to admin_edition_path(@edition, anchor: 'document-sources')
  end

  private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end
end
