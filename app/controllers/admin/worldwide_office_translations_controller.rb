class Admin::WorldwideOfficeTranslationsController < Admin::BaseController
  include Admin::TranslationsControllerConcern

  before_filter :load_translated_and_english_contact, except: :create
  helper_method :translation_locale

  private

  def create_redirect_path
    edit_admin_worldwide_organisation_worldwide_office_translation_path(@worldwide_organisation, @worldwide_office, id: translation_locale)
  end

  def update_attributes
    @translated_contact.update_attributes(contact_params)
  end

  def remove_translations
    @contact.remove_translations_for(translation_locale.code)
  end

  def destroy_redirect_path
    admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation)
  end

  def update_redirect_path
    admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation)
  end

  def load_translatable_items
    @worldwide_organisation = WorldwideOrganisation.find(params[:worldwide_organisation_id])
    @worldwide_office = @worldwide_organisation.offices.find(params[:worldwide_office_id])
    @contact = @worldwide_office.contact
  end

  def load_translated_and_english_contact
    @translated_contact = LocalisedModel.new(@contact, translation_locale.code, [:contact_numbers])
    @english_contact = LocalisedModel.new(@contact, :en, [:contact_numbers])
  end

  def translated_item
    @contact.title
  end

  def contact_params
    params.require(:contact)
          .permit(:title, :comments, :recipient, :street_address, :locality,
                  :region, :email, :contact_form_url,
                  contact_numbers_attributes: [:id, :label, :number])
  end
end
