class Admin::FeaturingsController < Admin::BaseController
  before_filter :load_edition
  before_filter :ensure_edition_is_featurable

  def create
    unless @edition.feature
      flash[:alert] = @edition.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  def update
    unless @edition.update_attributes(params[:edition])
      flash[:alert] = @edition.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  def destroy
    unless @edition.unfeature
      flash[:alert] = @edition.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  private

  def load_edition
    @edition = Edition.find(params[:document_id])
  end

  def ensure_edition_is_featurable
    unless @edition.featurable?
      redirect_to :back, alert: "#{@edition.class.to_s.underscore.humanize.pluralize} cannot be featured"
    end
  end
end
