total_count = FatalityNotice.count
changed_count = 0
FatalityNotice.where(roll_call_introduction: nil).find_each do |fn|
  fn.update_column(:roll_call_introduction, fn.summary)
  changed_count += 1
end

puts "Total: #{total_count}, changed: #{changed_count}"