class AddPaginateBodyFlagToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :paginate_body, :boolean, default: true
  end
end
