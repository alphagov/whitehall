class AddAttachmentSource < ActiveRecord::Migration
  def change
    create_table :attachment_sources do |t|
      t.references :attachment
      t.string :url
    end
  end
end
