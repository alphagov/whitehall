module Admin::OrganisationHelper
  def organisation_role_ordering_fields(outer_form, organisation_roles)
    outer_form.fields_for :organisation_roles, organisation_roles do |organisation_role_form|
      label_text = "#{organisation_role_form.object.role.name}<br/><strong>#{organisation_role_form.object.role.current_person_name}</strong>".html_safe
      content_tag(:div,
        organisation_role_form.text_field(:ordering, label_text: label_text, class: "ordering"),
        class: "well"
      )
    end
  end

  def organisation_tabs(organisation)
    {
      "Details" => admin_organisation_path(organisation),
      "Contacts" => admin_organisation_contacts_path(organisation),
      "Social media accounts" => admin_organisation_social_media_accounts_path(organisation),
      "About us" => about_admin_organisation_path(organisation),
      "Governance groups" => admin_organisation_groups_path(organisation),
      "People" => people_admin_organisation_path(organisation),
      "Featured documents" => documents_admin_organisation_path(organisation),
      "Document series" => document_series_admin_organisation_path(organisation),
      "Corporate information pages" => admin_organisation_corporate_information_pages_path(organisation),
    }
  end
end
