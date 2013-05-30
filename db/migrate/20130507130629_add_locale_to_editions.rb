class AddLocaleToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :locale, :string, default: 'en', null: false
    add_index :editions, :locale
  end
end
