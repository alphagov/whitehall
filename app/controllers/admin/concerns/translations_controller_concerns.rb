module Admin::TranslationsControllerConcerns
  extend ActiveSupport::Concern

  def create
    redirect_to create_redirect_path
  end

  def create_redirect_path
    raise "create_redirect_path should be overridden in the including controller"
  end
end
