values = []
Edition
  .joins(:translations)
  .where(state: [:published, :draft, :withdrawn])
  .pluck(:edition_id, :title)
  .each do |e|
    next if e[1].blank?
    e[1].parameterize.split('-').uniq.each do |component|
      values << "(#{e[0]}, '#{component}')"
    end
  end

values.each_slice(1000) do |v|
  Edition.connection.insert("INSERT INTO edition_title_terms VALUES#{v.join(', ')}")
end
