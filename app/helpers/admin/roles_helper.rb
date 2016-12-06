module Admin::RolesHelper
  def roles_footnotes(roles, including_cabinet)
    content_tag(:span, roles.map { |role| role.footnotes(including_cabinet) }.join(" ").html_safe)
  end

  def role_url_for(role)
    if role.new_record?
      admin_roles_path
    else
      admin_role_path(role.slug)
    end
  end
end
