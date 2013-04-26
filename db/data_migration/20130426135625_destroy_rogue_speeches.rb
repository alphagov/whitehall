speeches = [176664, 174043, 174061, 174060]
puts "Destroying speeches: #{speeches.join(', ')}"

documents = speeches.map { |id| Speech.unscoped.find(id).document }

puts "Destroying documents: #{documents.map(&:id).join(', ')}"
documents.each(&:destroy)

puts "Finished destruction."
