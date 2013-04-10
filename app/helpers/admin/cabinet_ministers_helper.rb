module Admin::CabinetMinistersHelper
  def ministers_role_ordering_fields(form, cabinet_minister_roles)
    cabinet_minister_roles.map do |role|
      label = role.name
      if role.current_person
        label << " (#{role.current_person.name})"
      end
      content_tag(:div,
        [label_tag("roles[#{role.id}][ordering]", link_to(label, [:edit, :admin, role.becomes(Role)])),
        text_field_tag("roles[#{role.id}][ordering]", role.seniority, class: "ordering")].join.html_safe, class: "well"
      )
    end.join.html_safe
  end
end
