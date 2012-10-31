class RenameYoutubeSocialMediaService < ActiveRecord::Migration
  def up
    update "UPDATE social_media_services SET name = 'YouTube' WHERE name = 'Youtube'"
  end

  def down
    # Intentionally blank
  end
end
