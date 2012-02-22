class SpeechType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name

  def slug
    name.downcase.gsub(/[^a-z]+/, "_")
  end

  Transcript       = create(id: 1, name: "Transcript")
  DraftText        = create(id: 2, name: "Draft text")
  SpeakingNotes    = create(id: 3, name: "Speaking notes")
  WrittenStatement = create(id: 4, name: "Written statement")
  OralStatement    = create(id: 5, name: "Oral statement")
end
