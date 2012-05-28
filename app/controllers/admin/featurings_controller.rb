class Admin::FeaturingsController < Admin::BaseController
  before_filter :load_edition
  before_filter :ensure_edition_is_featurable

  def create
    unless @document.feature
      flash[:alert] = @document.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  def update
    unless @document.update_attributes(params[:document])
      flash[:alert] = @document.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  def destroy
    unless @document.unfeature
      flash[:alert] = @document.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  private

  def load_edition
    @document = Edition.find(params[:document_id])
  end

  def ensure_edition_is_featurable
    unless @document.featurable?
      redirect_to :back, alert: "#{@document.class.to_s.underscore.humanize.pluralize} cannot be featured"
    end
  end
end
