class AddEmailAndCommentsToFactCheckRequest < ActiveRecord::Migration
  def change
    add_column :fact_check_requests, :email_address, :string
    add_column :fact_check_requests, :comments, :text
  end
end