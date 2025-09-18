class Admin::StandardEditionTranslationsController < Admin::BaseController
  before_action :load_translatable_item
  before_action :load_translated_models, except: %i[index new]
  helper_method :translation_locale

  before_action :prevent_modification_of_unmodifiable_edition

  def edit; end

private

  def load_translatable_item
    @edition ||= Edition.find(params[:standard_edition_id])
    enforce_permission!(:update, @edition)
    limit_edition_access!
  end

  def load_translated_models
    @translated_edition = LocalisedModel.new(@edition, translation_locale.code)
  end

  def translation_locale
    @translation_locale ||= Locale.new(params[:translation_locale] || params[:id])
  end
end
