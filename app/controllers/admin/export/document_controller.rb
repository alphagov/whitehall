class Admin::Export::DocumentController < Admin::Export::BaseController
  self.responder = Api::Responder

  def show
    @document = Document.find(params[:id])
    respond_with DocumentExportPresenter.new(@document)
  end
end
