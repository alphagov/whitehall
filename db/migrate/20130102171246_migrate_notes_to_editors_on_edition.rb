class MigrateNotesToEditorsOnEdition < ActiveRecord::Migration
  def up
    Edition.where('notes_to_editors !=""').each do |edition| 
      edition.update_attribute :body, "#{body}\n\n##Notes to editors\n\n#{edition.notes_to_editors}"
    end
    remove_column :editions, :notes_to_editors
  end

  def down
    add_column :editions, :notes_to_editors, :text
  end
end
