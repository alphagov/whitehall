class CreateFactCheckRequests < ActiveRecord::Migration
  def change
    create_table :fact_check_requests, :force => true do |t|
      t.integer :edition_id
      t.string :token
      t.timestamps
    end
  end
end