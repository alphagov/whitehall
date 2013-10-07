class CreateSnippets < ActiveRecord::Migration
  def change
    create_table :snippets do |t|
      t.string :key, unique: true
      t.text :body
      t.timestamps
    end
  end
end
