class Admin::ContactTranslationsController < Admin::BaseController
  before_filter :find_contactable, :find_contact
  helper_method :translation_locale

  def create
    redirect_to edit_admin_organisation_contact_translation_path(@contactable, @contact, id: translation_locale)
  end

  def edit
  end

private
  def translation_locale
    Locale.new(params[:translation_locale] || params[:id])
  end

  def find_contactable
    @contactable =
      if params.has_key?(:organisation_id)
        Organisation.find(params[:organisation_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def find_contact
    @contact = @contactable.contacts.find(params[:contact_id])
  end
end
