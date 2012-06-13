class RolePresenter < Draper::Base
  def url
    if ministerial?
      h.ministerial_role_url model
    end
  end

  def link
    if url
      h.link_to name, url
    else
      name
    end
  end
end