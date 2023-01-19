class AddContentIdToHistoricalAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :historical_accounts, :content_id, :string

    HistoricalAccount.all.each do |historical_account|
      historical_account.update(content_id: SecureRandom.uuid)
    end
  end
end
