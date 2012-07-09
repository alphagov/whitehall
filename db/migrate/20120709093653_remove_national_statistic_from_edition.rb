class RemoveNationalStatisticFromEdition < ActiveRecord::Migration
  def up
    execute "UPDATE editions SET publication_type_id = #{PublicationType::NationalStatistics.id} WHERE national_statistic = 1"
    remove_column :editions, :national_statistic
  end

  def down
    add_column :editions, :national_statistic, :boolean, default: false, null: false
  end
end
