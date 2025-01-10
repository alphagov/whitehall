class ContentBlockManager::UsersController < ContentBlockManager::BaseController
  def show
    @user = ContentBlockManager::SignonUser.with_uuids([params[:id]]).first

    raise ActiveRecord::RecordNotFound, "Could not find User with ID #{params[:id]}" if @user.blank?
  end
end
