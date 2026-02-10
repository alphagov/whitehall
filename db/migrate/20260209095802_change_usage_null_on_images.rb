class ChangeUsageNullOnImages < ActiveRecord::Migration[8.1]
  def change
    change_column_null :images, :usage, false
  end
end
