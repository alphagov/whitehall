module Admin::ContactsHelper
  def contact_translation_css_class(translated_contact)
    c = ["contact-translation"]
    c << "right-to-left" if translated_contact.translation_locale.rtl?
    c.join(" ")
  end
end
