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
    general_contacts = contacts.reject(&:foi?)
    if general_contacts.present?
      {
        id: "general_and_media_contacts",
        title: tab_title(title_text, general_contacts),
        label: title_text,
        content: render("admin/contacts/contacts", contacts: general_contacts, contactable:, title: "Translated general and media contacts")
      }
    end
  end

  def freedom_of_information_contacts_tab(contacts, contactable)
    title_text = "Freedom of information contacts"
    foi_contacts = contacts.select(&:foi?)
    if foi_contacts.present?
      {
        id: "freedom_of_information_contacts",
        title: tab_title(title_text, foi_contacts),
        label: title_text,
        content: render("admin/contacts/contacts", contacts: foi_contacts, contactable:, title: "Translated freedom of information contacts")
      }
    end
  end

  def tab_title(title_text, contacts)
    render("admin/contacts/tab_heading", title_text: title_text, contacts: contacts)
  end

  def contact_rows(contact, contactable)
    rows = contact_numbers(contact)
    rows << contact_email(contact)
    rows << contact_url(contact)
    rows << { key: "Contact type", value: contact.contact_type.name }
    rows << contact_address(contact)
    rows << set_homepage_contacts(contact, contactable)
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
        value: contact.email
      }
    end
  end

  def contact_url(contact)
    if contact.contact_form_url.present?
      {
        key: "Contact form",
        value: link_to(contact.contact_form_url.truncate(25), contact.contact_form_url)
      }
    end
  end

  def contact_address(contact)
    if render_hcard_address(contact).present?
      {
        key: "Address",
        value: render_hcard_address(contact)
      }
    end
  end

  def set_homepage_contacts(contact, contactable)
    {
      key: "On homepage",
      value: contact_shown_on_home_page_text(contact.contactable, contact),
      actions:
        if contactable.contact_shown_on_home_page?(contact)
          [{
            label: "Set to No",
            href: [:remove_from_home_page, :admin, contactable, contact]
          }]
        else
          [{
            label: "Set to Yes",
            href: [:add_to_home_page, :admin, contactable, contact]
          }]
        end,
    }
  end

  def contact_comments(contact)
    if contact.comments.present?
      {
        key: "",
        value: format_with_html_line_breaks(h(contact.comments))
      }
    end
  end
end
