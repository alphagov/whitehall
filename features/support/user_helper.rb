module UserHelper
  def begin_editing_user_details(name)
    visit admin_root_path
    click_link name
    click_link "Edit"
  end
end

World(UserHelper)