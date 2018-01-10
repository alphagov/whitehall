module Admin::CabinetMinistersHelper
  def ministers_role_ordering_fields(_form, cabinet_minister_roles, key)
    cabinet_minister_roles
      .map { |role|
        label = role.name
        label << " (#{role.current_person.name})" if role.current_person
        label_link = link_to(label, [:edit, :admin, role.becomes(Role)])

        form_element_name = "#{key}[#{role.id}][ordering]"

        form_elements = [
          label_tag(form_element_name, label_link),
          text_field_tag(form_element_name, yield(role), class: "ordering")
        ]

        content_tag(:div, form_elements.join.html_safe, class: "well")
      }
      .join
      .html_safe
  end

  def organisation_ordering_fields(organisations)
    organisations
      .map { |organisation|
        form_element_name = "organisation[#{organisation.id}][ordering]"

        form_elements = [
          label_tag(form_element_name, organisation.name),
          text_field_tag(form_element_name, organisation.ministerial_ordering, class: "ordering")
        ]

        content_tag(:div, form_elements.join.html_safe, class: "well")
      }
      .join
      .html_safe
  end
end
