class AddSlugToEditionsTable < ActiveRecord::Migration[8.1]
  def change
    # rubocop:disable Rails/BulkChangeTable
    add_column :editions, :slug, :string
    add_index :editions, %i[slug type]
    # rubocop:enable Rails/BulkChangeTable
  end
end
