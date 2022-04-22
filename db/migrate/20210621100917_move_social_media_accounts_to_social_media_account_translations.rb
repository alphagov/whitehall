class MoveSocialMediaAccountsToSocialMediaAccountTranslations < ActiveRecord::Migration[6.0]
  def up
    existing_social_media_accounts = ActiveRecord::Base.connection.execute("SELECT id, title, url, locale FROM social_media_accounts").to_a

    existing_social_media_accounts.each do |account|
      SocialMediaAccountTranslation.create!(
        social_media_account_id: account[0],
        title: account[1],
        url: account[2],
        locale: account[3],
      )
    end

    change_table :social_media_accounts do |t| # rubocop:disable Rails/BulkChangeTable
      t.remove :url, :title, :locale
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
