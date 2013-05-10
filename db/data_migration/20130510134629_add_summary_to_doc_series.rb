puts "Updating document series: "
count = 0
DocumentSeries.find_each do |ds|
  if ds.summary.blank?
    puts "Fixing: #{ds.name}"
    ds.update_column(:summary, "This series brings together all documents relating to #{ds.name}")
    count += 1
  end
end

puts " #{count} document series updated."
