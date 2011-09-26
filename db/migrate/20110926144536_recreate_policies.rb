class RecreatePolicies < ActiveRecord::Migration
  def change
    create_table :policies, :force => true do |t|
      t.timestamps
    end

    add_column :editions, :policy_id, :integer
  end
end