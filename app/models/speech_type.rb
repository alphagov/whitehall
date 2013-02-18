class SpeechType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :genus, :explanation, :key

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

  def self.non_statements
    [Transcript, DraftText, SpeakingNotes]
  end

  def statement_to_parliament?
    SpeechType.statements.include? self
  end

  def self.statements
    [WrittenStatement, OralStatement]
  end

  def search_format_types
    types = ['speech-'+self.name.parameterize]
    types << 'speech-statement-to-parliament' if statement_to_parliament?
    types
  end

  Transcript = create(
    id: 1, name: "Transcript", genus: "Speech", key: "transcript",
    explanation: "This is a transcript of the speech, exactly as it was delivered."
  )
  DraftText = create(
    id: 2, name: "Draft text", genus: "Speech", key: "draft_text",
    explanation: "This is the text of the speech as drafted, which may differ slightly from the delivered version."
  )
  SpeakingNotes = create(
    id: 3, name: "Speaking notes", genus: "Speech", key: "speaking_notes",
    explanation: "These are the speaker's notes, not a transcript of the speech as it was delivered."
  )
  WrittenStatement = create(id: 4, key: "written_statement", name: "Written statement to parliament")
  OralStatement = create(id: 5, key: "oral_statement", name: "Oral statement to parliament")
  ImportedAwaitingType = create(id: 1000, key: "imported", name: "Imported - Awaiting Type")
end
