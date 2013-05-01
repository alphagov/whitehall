class RemovePoliticalPartyIdFromHistoricalAccounts < ActiveRecord::Migration
  def change
    remove_column :historical_accounts, :political_party_id
  end
end
