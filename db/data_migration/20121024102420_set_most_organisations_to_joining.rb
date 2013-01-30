excluded_organisations = %w(DFT DCLG BRAC DSA).map { |a| Organisation.find_by_acronym!(a) }
excluded_organisations << Organisation.find_by_name!('Planning inspectorate')

included_organisations = Organisation.all.reject { |o| excluded_organisations.include?(o) }

MinisterialRoleSearchIndexObserver.while_disabled do
  included_organisations.each do |organisation|
    $stderr.print "Setting status of '#{organisation.name}' to 'joining'..."
    organisation.update_attributes!(govuk_status: 'joining')
    $stderr.puts "[done]"
  end
end

$stderr.print "Re-indexing ministerial roles..."
Rummageable.index(MinisterialRole.search_index, Whitehall.government_search_index_path)
$stderr.puts "[done]"
