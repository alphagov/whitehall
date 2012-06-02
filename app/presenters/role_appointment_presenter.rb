class RoleAppointmentPresenter < Draper::Base
  def url
    if role.ministerial?
      h.ministerial_role_url role
    end
  end

  def link
    if url
      h.link_to role.name, url
    else
      role.name
    end
  end
end