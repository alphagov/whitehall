class SpeechType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :genus, :explanation

  def slug
    name.downcase.gsub(/[^a-z]+/, "-")
  end

  def genus
    @genus || @name
  end

  def self.find_by_name(name)
    all.find { |pt| pt.name == name }
  end

  def self.find_by_slug(slug)
    all.find { |type| type.slug == slug }
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
  ImportedAwaitingType = create(id: 1000, name: "Imported - Awaiting Type")
end
