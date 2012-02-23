class SpeechType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :genus, :explanation

  def slug
    name.downcase.gsub(/[^a-z]+/, "_")
  end

  def genus
    @genus || @name
  end

  Transcript = create(
    id: 1, name: "Transcript", genus: "Speech",
    explanation: "This is a transcript of the speech, exactly as it was delivered."
  )
  DraftText = create(
    id: 2, name: "Draft text", genus: "Speech",
    explanation: "This is the text of the speech as drafted, which may differ slightly from the delivered version."
  )
  SpeakingNotes = create(
    id: 3, name: "Speaking notes", genus: "Speech",
    explanation: "These are the speaker's notes, not a transcript of the speech as it was delivered."
  )
  WrittenStatement = create(id: 4, name: "Written statement")
  OralStatement = create(id: 5, name: "Oral statement")
end
