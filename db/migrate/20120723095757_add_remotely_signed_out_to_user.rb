class AddRemotelySignedOutToUser < ActiveRecord::Migration
  def change
    add_column :users, :remotely_signed_out, :boolean, default: false
  end
end
