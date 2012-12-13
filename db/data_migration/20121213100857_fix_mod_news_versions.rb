mod = Organisation.find_by_slug('ministry-of-defence')

return unless mod

count = 0
# for each document that is a news article in MOD
Document.find_by_sql("SELECT d.* FROM documents d left join editions e on d.id = e.document_id left join edition_organisations eo ON eo.edition_id = e.id WHERE eo.organisation_id = #{mod.id} and document_type in ('NewsArticle','FatalityNotice')").each do |document|
#  get all the editions sorted by creation ASC
  editions = Edition.unscoped.where('document_id = ?', document.id).order('id ASC')
  #  for each edition in the document
  editions.each_with_index do |edition, i|
    next if Edition::PRE_PUBLICATION_STATES.include?(edition.state)
    #   change the major version to 1
    edition.update_column(:published_major_version, 1)
    #   change minor version to be i
    edition.update_column(:published_minor_version, i)
    #   change minor_change to true
    if i > 0
      edition.update_column(:minor_change, true)
    end
    #   call edition.set_timestamp_for_sorting
    edition.update_column(:timestamp_for_sorting, edition.first_published_at)
    #  end for
  end
  count += 1
  # end for
end && nil
puts "#{count} documents updated"
