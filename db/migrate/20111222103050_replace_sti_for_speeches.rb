class ReplaceStiForSpeeches < ActiveRecord::Migration
  def up
    create_table :speech_types, force: true do |t|
      t.string :name
      t.timestamps
    end
    add_column :documents, :speech_type_id, :integer
    
    {
      Transcript: "Transcript",
      DraftText: "Draft text",
      SpeakingNotes: "Speaking notes",
      WrittenStatement: "Written statement",
      OralStatement: "Oral statement"
    }.each do |speech_type, speech_type_name|
      speech_type_id = insert "INSERT INTO speech_types (name) VALUE ('#{speech_type_name}')"
      
      update "UPDATE documents 
              SET speech_type_id = #{speech_type_id},
              type = 'Speech'
              WHERE type = 'Speech::#{speech_type}'"
    end
  end
  def down
    raise ActiveRecord::IrreversibleMigration, "Reverting this migration will result in a loss of data. It's possible to write the SQL necessary to avoid data loss but I didn't see it as important enough. Feel free to add it if it's going to be useful."
    
    # drop_table :speech_types
    # remove_column :documents, :speech_type_id
  end
end