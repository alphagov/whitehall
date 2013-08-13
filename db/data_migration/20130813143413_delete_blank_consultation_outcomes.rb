require 'benchmark'

time = Benchmark.realtime do
  blank_outcomes = ConsultationOutcome.all.select {|co| co.summary.blank? && co.attachments.empty? }

  puts "Deleting #{blank_outcomes.size} blank consultation outcomes"
  blank_outcomes.each do |outcome|
    outcome.destroy
    print '.'
  end
  puts "\nAll done"
end

puts time
