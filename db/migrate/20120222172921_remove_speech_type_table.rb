class RemoveSpeechTypeTable < ActiveRecord::Migration
  def up
    drop_table :speech_types
  end

  def down
    create_table :speech_types do |t|
      t.string :name
      t.timestamps
    end

    {
      Transcript: "Transcript",
      DraftText: "Draft text",
      SpeakingNotes: "Speaking notes",
      WrittenStatement: "Written statement",
      OralStatement: "Oral statement"
    }.each do |speech_type, speech_type_name|
      speech_type_id = insert "INSERT INTO speech_types (name) VALUE ('#{speech_type_name}')"
    end
      
    update <<-SQL
      UPDATE documents 
      SET speech_type_id = #{speech_type_id},
      type = 'Speech'
      WHERE type = 'Speech::#{speech_type}'
    SQL
  end
end
