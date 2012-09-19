class RemovePaginateBodyFromEditions < ActiveRecord::Migration
  def change
    remove_column :editions, :paginate_body
  end
end
