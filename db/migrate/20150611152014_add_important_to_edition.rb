class AddImportantToEdition < ActiveRecord::Migration
  def change
    add_column :editions, :important, :boolean, default: false
  end
end
