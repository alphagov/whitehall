class RemoveCommandPaperNumberFromPublications < ActiveRecord::Migration
  def up
    remove_column :editions, :command_paper_number
  end

  def down
    add_column :editions, :command_paper_number, :string
  end
end
