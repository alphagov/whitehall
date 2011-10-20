class AddInstructionsToFactCheckRequests < ActiveRecord::Migration
  def change
    add_column :fact_check_requests, :instructions, :text
  end
end