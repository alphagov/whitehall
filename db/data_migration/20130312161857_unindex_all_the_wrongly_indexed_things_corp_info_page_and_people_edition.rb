# Corp info pages belonging to non-live orgs should be removed
CorporateInformationPage.joins("
  LEFT OUTER JOIN organisations ON
  corporate_information_pages.organisation_id = organisations.id AND
  corporate_information_pages.organisation_type = 'Organisation'").
where("(#{Organisation.arel_table[:id].not_eq(nil).to_sql} AND #{Organisation.arel_table[:govuk_status].not_eq('live').to_sql})").
each do |wrongly_indexed_corp_info_page|
  wrongly_indexed_corp_info_page.remove_from_search_index
end

# People that have no role should be added
# is easier to remove all and reindex
Person.all.map(&:remove_from_search_index)
Rummageable.index(Person.search_index, Whitehall.government_search_index_path)


