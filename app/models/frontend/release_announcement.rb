class Frontend::ReleaseAnnouncement
  attr_reader :title, :document_type, :release_date, :organisations

  def initialize(attrs = {})
    attrs = HashWithIndifferentAccess.new(attrs)
    @title = attrs[:title]
    @document_type = attrs[:document_type]
    @release_date = attrs[:release_date]
    @release_date_text = attrs[:release_date_text]
    @organisations = attrs[:organisations]
  end

  def release_date_text
    @release_date_text || @release_date.to_s(:long)
  end

  def to_partial_path
    "release_announcement"
  end
end
