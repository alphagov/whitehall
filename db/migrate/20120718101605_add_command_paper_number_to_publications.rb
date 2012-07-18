class AddCommandPaperNumberToPublications < ActiveRecord::Migration
  def change
    add_column :editions, :command_paper_number, :string
  end
end