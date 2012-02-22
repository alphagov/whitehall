class SpeechType
  include ActiveRecordLikeInterface

  attr_reader :id, :name, :slug

  def initialize(id, name)
    @name = name
    @slug = name.downcase.gsub(/ /, "_")
    @id   = id
  end

  Transcript       = create(1, "Transcript")
  DraftText        = create(2, "Draft text")
  SpeakingNotes    = create(3, "Speaking notes")
  WrittenStatement = create(4, "Written statement")
  OralStatement    = create(5, "Oral statement")
end
