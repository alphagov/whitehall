class AddPoliticalPartyIdsToHistoricalAccounts < ActiveRecord::Migration
  def change
    add_column :historical_accounts, :political_party_ids, :string
  end
end
