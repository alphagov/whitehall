class AddOrderingToSocialMediaAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :social_media_accounts, :ordering, :integer
  end
end
