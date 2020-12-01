class AddLocaleToSocialMediaAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :social_media_accounts, :locale, :string, default: "en"
  end
end
