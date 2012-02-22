class SpeechType
  attr_reader :id, :name, :slug

  def self.primary_key
    :id
  end

  def self.repository
    @repository ||= {}
  end

  def self.find_by_id(id)
    repository[id]
  end

  def self.all
    repository.values
  end

  def self.create(id, name)
    repository[id] = new(id, name)
  end

  def initialize(id, name)
    @name = name
    @slug = name.downcase.gsub(/ /, "_")
    @id   = id
  end

  def [](key)
    __send__(key)
  end

  def destroyed?
    false
  end

  def new_record?
    false
  end

  Transcript       = create(1, "Transcript")
  DraftText        = create(2, "Draft text")
  SpeakingNotes    = create(3, "Speaking notes")
  WrittenStatement = create(4, "Written statement")
  OralStatement    = create(5, "Oral statement")
end
