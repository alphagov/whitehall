class ChangeEditionFieldsToDateTime < ActiveRecord::Migration
  def change
   change_column :editions, :delivered_on, :datetime
   change_column :editions, :publication_date, :datetime
  end
end
