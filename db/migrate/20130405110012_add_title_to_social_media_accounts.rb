class AddTitleToSocialMediaAccounts < ActiveRecord::Migration
  def change
    add_column :social_media_accounts, :title, :string
  end
end
