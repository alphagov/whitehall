class Admin::FeaturingsController < Admin::BaseController
  before_filter :load_document
  before_filter :ensure_document_is_featurable, only: [:create]

  def create
    @document.feature
    redirect_to :back
  end

  def destroy
    @document.unfeature
    redirect_to :back
  end

  private

  def load_document
    @document = Document.find(params[:document_id])
  end

  def ensure_document_is_featurable
    unless @document.featurable?
      redirect_to :back, alert: "#{@document.class.to_s.underscore.humanize.pluralize} cannot be featured"
    end
  end
end
