class MakeEditionBodyAMediumtext < ActiveRecord::Migration
  def up
    change_column :editions, :body, :text, limit: (16.megabytes - 1)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "data may be lost shrinking document bodies"
  end
end
