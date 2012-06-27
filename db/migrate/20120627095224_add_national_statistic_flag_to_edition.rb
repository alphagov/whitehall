class AddNationalStatisticFlagToEdition < ActiveRecord::Migration
  def change
    add_column :editions, :national_statistic, :boolean, default: false, null: false
  end
end
