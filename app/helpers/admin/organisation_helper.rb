module Admin::OrganisationHelper
  def organisation_role_ordering_fields(outer_form, organisation_roles)
    outer_form.fields_for :organisation_roles, organisation_roles do |organisation_role_form|
      role_name = link_to(organisation_role_form.object.role.name, [:edit, :admin, organisation_role_form.object.role.becomes(Role)])
      if organisation_role_form.object.role.current_person
        name = link_to(organisation_role_form.object.role.current_person_name, [:edit, :admin, organisation_role_form.object.role.current_person])
        label_text = "#{role_name}<br/><strong>#{name}</strong>".html_safe
      else
        label_text = "#{role_name}<br/><strong>#{organisation_role_form.object.role.current_person_name}</strong>".html_safe
      end
      content_tag(:div,
        organisation_role_form.text_field(:ordering, label_text: label_text, class: "ordering"),
        class: "well"
      )
    end
  end

  def organisation_tabs(organisation)
    tabs = {
      "Details" => admin_organisation_path(organisation),
      "Contacts" => admin_organisation_contacts_path(organisation),
      "Document series" => document_series_admin_organisation_path(organisation),
    }
    if organisation.executive_office?
      tabs["Featured topics and policies"] = admin_organisation_featured_topics_and_policies_list_path(organisation)
      tabs["Promotional features"] = admin_organisation_promotional_features_path(organisation)
    end

    tabs["Featured documents"] = features_admin_organisation_path(organisation, locale: nil)
    organisation.non_english_translated_locales.each do |locale|
      tabs["Featured documents (#{locale.native_language_name})"] = features_admin_organisation_path(organisation, locale: locale.code)
    end

    tabs["More"] = {
      "About us" => about_admin_organisation_path(organisation),
      "Social media accounts" => admin_organisation_social_media_accounts_path(organisation),
      "Governance groups" => admin_organisation_groups_path(organisation),
      "People" => people_admin_organisation_path(organisation),
      "Corporate information pages" => admin_organisation_corporate_information_pages_path(organisation),
      "Translations" => admin_organisation_translations_path(organisation),
      "Financial Reports" => admin_organisation_financial_reports_path(organisation)
    }
    tabs
  end

  def contact_shown_on_home_page_text(organisation, contact)
    if contact.foi?
      "Yes (in FOI section)"
    elsif organisation.contact_shown_on_home_page?(contact)
      "Yes"
    else
      "No"
    end
  end

end
