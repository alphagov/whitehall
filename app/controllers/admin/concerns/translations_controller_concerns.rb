module Admin::TranslationsControllerConcerns
  extend ActiveSupport::Concern

  def create
    redirect_to create_redirect_path
  end

  def edit
  end

  def update
    if update_attributes
      redirect_to update_redirect_path, notice: notice_message("saved")
    else
      render action: 'edit'
    end
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end

  def create_redirect_path
    raise "create_redirect_path should be overridden in the including controller"
  end

  def update_attributes
    raise "update_attributes should be overridden in the including controller"
  end

  def update_redirect_path
    raise "update_redirect_path should be overridden in the including controller"
  end
end
