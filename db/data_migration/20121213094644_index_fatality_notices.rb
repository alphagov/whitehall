fatality_notice_data = [FatalityNotice].map(&:search_index).sum([])
p fatality_notice_data
Rummageable.index(fatality_notice_data, Whitehall.government_search_index_name)
Rummageable.commit(Whitehall.government_search_index_name)
