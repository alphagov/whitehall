class Frontend::ReleaseAnnouncement
  attr_reader :title, :document_type, :release_date, :organisations

  def initialize(attrs = {})
    attrs = HashWithIndifferentAccess.new(attrs)
    @title = attrs[:title]
    @document_type = attrs[:document_type]
    @release_date = attrs[:release_date]
    @release_date_text = attrs[:release_date_text]
    @organisations = build_organisations Array(attrs[:organisations])
  end

  def release_date_text
    @release_date_text || @release_date.to_s(:long)
  end

  def to_partial_path
    "release_announcement"
  end

private
  def build_organisations(organisation_hashes)
    organisation_hashes.map do |org_hash|
      if org_hash.is_a? Organisation
        org_hash
      else
        Organisation.new(org_hash)
      end
    end
  end

  class Organisation
    attr_reader :slug, :name

    def initialize(attrs = {})
      attrs = HashWithIndifferentAccess.new(attrs)
      @name = attrs[:name]
      @slug = attrs[:slug]
    end

    def to_param
      slug
    end
  end
end
