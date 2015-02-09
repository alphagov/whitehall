class RemoveEditionsLocaleColumn < ActiveRecord::Migration
  def change
    remove_column :editions, :locale
  end
end
