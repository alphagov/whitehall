puts "INFO: #{EditionDependency.count} edition dependencies exist"
puts "INFO: Populating dependencies for #{CaseStudy.published.count} published case studies"
index = 0
CaseStudy.published.find_each do |case_study|
  EditionDependenciesPopulator.new(case_study).populate!
  print '.' if ((index += 1) % 10).zero?
end
puts ""
puts "INFO: Now, #{EditionDependency.count} edition dependencies exist"
puts "INFO: Done."
