def log_message
  %(
    Number of WorldwideOffices: #{WorldwideOffice.count},
    Number of WorldwideOffices with content_id: #{WorldwideOffice.where.not(content_id: nil).count}
    Number of WorldwideOffices without content_id: #{WorldwideOffice.where(content_id: nil).count}
  )
end

puts "BEFORE: #{log_message}"

WorldwideOffice.where(content_id: nil).each do |office|
  office.update!(content_id: SecureRandom.uuid)
end

puts "AFTER: #{log_message}"
