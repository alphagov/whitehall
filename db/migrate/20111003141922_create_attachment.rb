class CreateAttachment < ActiveRecord::Migration
  def change
    remove_column :editions, :attachment
    add_column :editions, :attachment_id, :integer
    create_table :attachments, force: true do |t|
      t.string :name
      t.timestamps
    end
  end
end