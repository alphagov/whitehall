class AddAuthorToPolicy < ActiveRecord::Migration
  def change
    add_column :policies, :author_id, :integer
  end
end