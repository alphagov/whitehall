# Find any document with more than one published edition
document_ids = DetailedGuide.published.group(:document_id).having('COUNT(*) > 1').count.keys

Document.find(document_ids).each do |document|
  editions = document.editions.published

  # Find the latest edition by comparing version numbers
  latest = editions.reduce do |a, b|
    if a.published_major_version > b.published_major_version
      a
    elsif a.published_major_version < b.published_major_version
      b
    elsif a.published_minor_version > b.published_minor_version
      a
    elsif a.published_minor_version < b.published_minor_version
      b
    else
      throw "Editions have the same version"
    end
  end

  # Archive everything except the latest edition
  editions.reject { |edition| edition == latest }.each(&:archive!)
end
