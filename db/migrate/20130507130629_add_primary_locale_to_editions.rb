class AddPrimaryLocaleToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :primary_locale, :string, default: 'en', null: false
    add_index :editions, :primary_locale
  end
end
