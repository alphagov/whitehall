module Admin::DocumentsController::Featurable
  extend ActiveSupport::Concern

  def feature
    document_class.find(params[:id]).feature
    redirect_to :back
  end

  def unfeature
    document_class.find(params[:id]).unfeature
    redirect_to :back
  end

end