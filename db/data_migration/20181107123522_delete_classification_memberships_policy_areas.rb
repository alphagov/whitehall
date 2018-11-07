ClassificationMembership.all.each_with_index do |membership, index|
  membership.destroy if membership.classification.nil?
  puts ClassificationMembership.count - index if (index % 10000).zero?
end
