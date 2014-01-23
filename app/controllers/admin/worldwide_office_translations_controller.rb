class Admin::WorldwideOfficeTranslationsController < Admin::BaseController
  before_filter :find_organisation, :find_office
  before_filter :load_translated_and_english_contact, except: :create
  helper_method :translation_locale

  def create
    redirect_to edit_admin_worldwide_organisation_worldwide_office_translation_path(@worldwide_organisation, @worldwide_office, id: translation_locale)
  end

  def edit
  end

  def update
    if @translated_contact.update_attributes(contact_params)
      redirect_to admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation),
                  notice: notice_message("saved")
    else
      render action: "edit"
    end
  end

  def destroy
    @contact.remove_translations_for(translation_locale.code)
    redirect_to admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation),
                notice: notice_message("deleted")
  end

private
  def translation_locale
    Locale.new(params[:translation_locale] || params[:id])
  end

  def find_organisation
    @worldwide_organisation = WorldwideOrganisation.find(params[:worldwide_organisation_id])
  end

  def find_office
    @worldwide_office = @worldwide_organisation.offices.find(params[:worldwide_office_id])
    @contact = @worldwide_office.contact
  end

  def load_translated_and_english_contact
    @translated_contact = LocalisedModel.new(@contact, translation_locale.code, [:contact_numbers])
    @english_contact = LocalisedModel.new(@contact, :en, [:contact_numbers])
  end

  def notice_message(action)
    %{#{translation_locale.english_language_name} translation for "#{@contact.title}" #{action}.}
  end

  def contact_params
    params.require(:contact)
          .permit(:title, :comments, :recipient, :street_address, :locality,
                  :region, :email, :contact_form_url,
                  contact_numbers_attributes: [:id, :label, :number])
  end
end
