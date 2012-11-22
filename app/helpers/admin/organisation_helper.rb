module Admin::OrganisationHelper
  def organisation_role_ordering_fields(outer_form, organisation_roles)
    outer_form.fields_for :organisation_roles, organisation_roles do |organisation_role_form|
      label_text = "#{organisation_role_form.object.role.name}, #{organisation_role_form.object.role.current_person_name}"
      content_tag(:div,
        organisation_role_form.text_field(:ordering, label_text: label_text, class: "ordering"),
        class: "well"
      )
    end
  end
end
