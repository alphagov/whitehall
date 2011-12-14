module Admin::DocumentsController::Featurable
  extend ActiveSupport::Concern

  def feature
    document_class.find(params[:id]).update_attribute(:featured, true)
    redirect_to :back
  end

  def unfeature
    document_class.find(params[:id]).update_attribute(:featured, false)
    redirect_to :back
  end

end