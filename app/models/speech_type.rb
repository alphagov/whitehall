class SpeechType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :plural_name, :genus_key, :explanation, :key, :owner_key_group, :published_externally_key, :location_relevant

  def self.create(attributes)
    super({
      owner_key_group: "delivery_title",
      published_externally_key: "delivered_on",
      location_relevant: true
    }.merge(attributes))
  end

  def slug
    name.downcase.gsub(/[^a-z]+/, "-")
  end

  def display_type_key
    @genus_key || @key
  end

  def self.find_by_name(name)
    all.detect { |type| type.name == name }
  end

  def self.find_by_slug(slug)
    all.detect { |type| type.slug == slug }
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

  def written_article?
    [AuthoredArticle].include? self
  end

  def search_format_types
    types = ['speech-' + self.name.parameterize]
    types << 'speech-statement-to-parliament' if statement_to_parliament?
    types
  end

  Transcript = create(
    id: 1, name: "Transcript", genus_key: "speech", key: "transcript",
    explanation: "Transcript of the speech, exactly as it was delivered",
    plural_name: "Transcripts"
  )

  DraftText = create(
    id: 2, name: "Draft text", genus_key: "speech", key: "draft_text",
    explanation: "Original script, may differ from delivered version",
    plural_name: "Draft texts"
  )

  SpeakingNotes = create(
    id: 3, name: "Speaking notes", genus_key: "speech", key: "speaking_notes",
    explanation: "Speaker's notes, may differ from delivered version",
    plural_name: "Speaking notes"
  )

  WrittenStatement = create(
    id: 4, key: "written_statement", name: "Written statement to Parliament",
    plural_name: "Written statements to Parliament"
  )

  OralStatement = create(
    id: 5, key: "oral_statement", name: "Oral statement to Parliament",
    plural_name: "Oral statements to Parliament"
  )

  AuthoredArticle = create(
    id: 6, key: "authored_article", name: "Authored article",
    owner_key_group: "author_title", published_externally_key: "written_on", location_relevant: false,
    plural_name: "Authored article"
  )

  ImportedAwaitingType = create(
    id: 1000, key: "imported", name: "Imported - Awaiting Type", plural_name: "Imported"
  )
end
