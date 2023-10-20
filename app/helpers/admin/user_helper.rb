module Admin::UserHelper
  def show_world_locations(user)
    if user.world_locations.present?
      user.world_locations.join(", ", &:name)
    else
      ""
    end
  end

  def show_edit_link(user)
    if user.editable_by?(current_user)
      {
        href: edit_admin_user_path(user),
        link_text: "Edit",
      }
    else
      {}
    end
  end
end
