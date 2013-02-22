class ContactPresenter < Draper::Base
  # delegate all the Contact methods
  # would prefer Contact.columns - [<unwnated>] + [<methods>], but that
  # gives syntax errors :(
  delegate :latitude, :longitude, :email, :contact_form_url,
    :title, :comments, :recipient,
    :street_address, :locality, :region, :postal_code,
    :contactable, :contact_numbers, :country,
    :mappable?, :has_postal_address?, :country_code, :country_name,
    to: :current_contact

  def current_contact
    if model.respond_to?(:contact)
      model.contact
    else
      model
    end
  end

  def services
    if model.respond_to?(:services)
      model.services
    else
      []
    end
  end
end
