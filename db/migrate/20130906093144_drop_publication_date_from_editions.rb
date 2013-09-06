class DropPublicationDateFromEditions < ActiveRecord::Migration
  def change
    remove_column :editions, :publication_date
  end
end
