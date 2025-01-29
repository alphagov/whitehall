class ChangeContentBlockEditionChangeNoteFieldsToText < ActiveRecord::Migration[7.2]
  def up
    change_table :content_block_editions, bulk: true do |t|
      t.change :internal_change_note, :text
      t.change :change_note, :text
    end
  end

  def down
    change_table :content_block_editions, bulk: true do |t|
      t.change :internal_change_note, :string
      t.change :change_note, :string
    end
  end
end
