class AddLogoUrlToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :logo_url, :string
  end
end
