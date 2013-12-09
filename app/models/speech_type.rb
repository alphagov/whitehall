class SpeechType
  include ActiveRecordLikeInterface

  attr_accessor :id, :singular_name, :plural_name, :explanation, :key, :owner_key_group, :published_externally_key, :location_relevant, :prevalence, :use_key_as_display_key

  def self.create(attributes)
    super({
      owner_key_group: "delivery_title",
      published_externally_key: "delivered_on",
      location_relevant: true
    }.merge(attributes))
  end

  def slug
    singular_name.downcase.gsub(/[^a-z]+/, "-")
  end

  def self.find_by_name(name)
    all.detect { |type| type.singular_name == name }
  end

  def self.find_by_slug(slug)
    all.detect { |type| type.slug == slug }
  end

  def self.non_statements
    [Transcript, DraftText, SpeakingNotes]
  end

  def self.primary
    all - use_discouraged
  end

  def self.use_discouraged
    [ImportedAwaitingType]
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
    types = ['speech-' + self.singular_name.parameterize]
    types << 'speech-statement-to-parliament' if statement_to_parliament?
    types
  end

  def genus_key
    'speech'
  end

  def display_type_key
    use_key_as_display_key ? key : genus_key
  end

  Transcript = create(
    id: 1, singular_name: "Transcript", key: "transcript",
    explanation: "Transcript of the speech, exactly as it was delivered",
    plural_name: "Transcripts"
  )

  DraftText = create(
    id: 2, singular_name: "Draft text", key: "draft_text",
    explanation: "Original script, may differ from delivered version",
    plural_name: "Draft texts"
  )

  SpeakingNotes = create(
    id: 3, singular_name: "Speaking notes", key: "speaking_notes",
    explanation: "Speaker's notes, may differ from delivered version",
    plural_name: "Speaking notes"
  )

  WrittenStatement = create(
    id: 4, key: "written_statement", singular_name: "Written statement to Parliament",
    plural_name: "Written statements to Parliament", use_key_as_display_key: true
  )

  OralStatement = create(
    id: 5, key: "oral_statement", singular_name: "Oral statement to Parliament",
    plural_name: "Oral statements to Parliament", use_key_as_display_key: true
  )

  AuthoredArticle = create(
    id: 6, key: "authored_article", singular_name: "Authored article",
    owner_key_group: "author_title", published_externally_key: "written_on", location_relevant: false,
    plural_name: "Authored article", use_key_as_display_key: true
  )

  ImportedAwaitingType = create(
    id: 1000, key: "imported", singular_name: "Imported - Awaiting Type", plural_name: "Imported"
  )
end
