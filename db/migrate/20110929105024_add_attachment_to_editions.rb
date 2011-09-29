class AddAttachmentToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :attachment, :string
  end
end
