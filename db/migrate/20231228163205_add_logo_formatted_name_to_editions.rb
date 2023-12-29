class AddLogoFormattedNameToEditions < ActiveRecord::Migration[7.0]
  def change
    add_column :editions, :logo_formatted_name, :string
  end
end
