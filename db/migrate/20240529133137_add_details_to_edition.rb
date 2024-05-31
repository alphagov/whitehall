class AddDetailsToEdition < ActiveRecord::Migration[7.1]
  def change
    add_column :editions, :details, :json, default: {}
  end
end
