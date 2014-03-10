class Frontend::StatisticalReleaseAnnouncement < InflatableModel
  attr_accessor :slug, :title, :summary, :document_type, :expected_release_date, :display_release_date, :organisations, :topics

  def release_date_text
    @display_release_date || @expected_release_date.to_s(:long)
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
