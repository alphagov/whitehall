class CreateHistoricalAccounts < ActiveRecord::Migration
  def change
    create_table :historical_accounts do |t|
      t.references  :person
      t.text        :summary
      t.text        :body
      t.string      :born
      t.string      :died
      t.references  :political_party
      t.text        :major_acts
      t.text        :interesting_facts

      t.timestamps
    end
    add_index :historical_accounts, :person_id
    add_index :historical_accounts, :political_party_id
  end
end
