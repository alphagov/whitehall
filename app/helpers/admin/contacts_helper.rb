module Admin::ContactsHelper
  def contact_translation_css_class(translated_contact)
    c = %w[contact-translation]
    c << "right-to-left" if translated_contact.translation_locale.rtl?
    c.join(" ")
  end

  def contact_tabs(contacts, contactable)
    tabs = []
    tabs << general_and_media_contacts_tab(contacts, contactable)
    tabs << freedom_of_information_contacts_tab(contacts, contactable)
    tabs.compact
  end

  def general_and_media_contacts_tab(contacts, contactable)
    title_text = "General and media contacts"
    general_contacts = (contactable.home_page_contacts + contacts.reject(&:foi?)).uniq
    if general_contacts.present?
      {
        id: "general_and_media_contacts",
        title: tab_title(title_text, general_contacts, contactable),
        label: title_text,
        tab_data_attributes: {
          module: "gem-track-click",
          "track-category": "tab",
          "track-action": "contact-general-tab",
          "track-label": title_text,
        },
        content: render("admin/contacts/contacts", contacts: general_contacts, contactable:, title: "Translated general and media contacts"),
      }
    end
  end

  def freedom_of_information_contacts_tab(contacts, contactable)
    title_text = "Freedom of information contacts"
    foi_contacts = contacts.select(&:foi?)
    if foi_contacts.present?
      {
        id: "freedom_of_information_contacts",
        title: tab_title(title_text, foi_contacts, contactable),
        label: title_text,
        tab_data_attributes: {
          module: "gem-track-click",
          "track-category": "tab",
          "track-action": "contact-foi-tab",
          "track-label": title_text,
        },
        content: render("admin/contacts/contacts", contacts: foi_contacts, contactable:, title: "Translated freedom of information contacts"),
      }
    end
  end

  def tab_title(title_text, contacts, contactable)
    render("admin/contacts/tab_heading", title_text:, contacts:, contactable:)
  end

  def contact_rows(contact)
    rows = contact_numbers(contact)
    rows << contact_email(contact)
    rows << contact_url(contact)
    rows << { key: "Contact type", value: contact.contact_type.name }
    rows << contact_address(contact)
    rows << homepage_contacts(contact)
    rows << { key: "Markdown code", value: "[Contact:#{contact.id}]" }
    rows << contact_comments(contact)
    rows.compact
  end

  def contact_numbers(contact)
    contact.contact_numbers.map do |cn|
      {
        key: cn.label,
        value: cn.number,
      }
    end
  end

  def contact_email(contact)
    if contact.email?
      {
        key: "Email",
        value: contact.email,
      }
    end
  end

  def contact_url(contact)
    if contact.contact_form_url.present?
      {
        key: "Contact form",
        value: contact.contact_form_url.truncate(25),
        actions: [
          {
            label: "View",
            href: contact.contact_form_url,
          },
        ],
      }
    end
  end

  def contact_address(contact)
    if render_hcard_address(contact).present?
      {
        key: "Address",
        value: render_hcard_address(contact),
      }
    end
  end

  def homepage_contacts(contact)
    {
      key: "On homepage",
      value: contact_shown_on_home_page_text(contact.contactable, contact),
    }
  end

  def contact_comments(contact)
    if contact.comments.present?
      {
        key: "Comments",
        value: contact.comments,
      }
    end
  end

  def any_translated_contacts?(contactable)
    contactable.contacts.any? { |contact| contact.non_english_localised_models([:contact_numbers]).present? }
  end
end
