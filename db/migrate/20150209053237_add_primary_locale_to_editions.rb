class AddPrimaryLocaleToEditions < ActiveRecord::Migration
  def up
    add_column :editions, :primary_locale, :string, default: "en", null: false

    Edition.reset_column_information
    Edition.update_all("primary_locale = locale")
  end

  def down
    remove_column :editions, :primary_locale
  end
end
