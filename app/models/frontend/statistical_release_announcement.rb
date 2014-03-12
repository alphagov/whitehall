class Frontend::StatisticalReleaseAnnouncement < InflatableModel
  attr_accessor :slug, :title, :summary, :document_type, :release_date, :release_date_text, :organisations, :topics

  def release_date_text
    @release_date_text || release_date.to_s(:long)
  end

  def release_date=(date_value)
    date_value = Time.zone.parse(date_value) if date_value.is_a? String
    @release_date = date_value
  end

  def to_partial_path
    "statistical_release_announcement"
  end

private
  def build_organisations(organisation_hashes)
    organisation_hashes.map do |org_hash|
      if org_hash.is_a? Organisation
        org_hash
      else
        Frontend::OrganisationMetadata.new(org_hash)
      end
    end
  end
end
