class PrepareUsersForGdsSso < ActiveRecord::Migration
  def change
    add_column :users, :uid, :string
    rename_column :users, :email_address, :email
    add_column :users, :version, :integer
  end
end