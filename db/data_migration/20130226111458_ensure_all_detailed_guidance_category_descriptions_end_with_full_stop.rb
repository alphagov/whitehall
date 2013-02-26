MainstreamCategory.all
  .reject { |c| c.description =~ /\.\s*$/ }
  .reject {|c| c.description.nil?}
  .each do |c|
    new_description = c.description.strip + "."
    puts "Category: #{c.title}"
    puts "Old decription: #{c.description}"
    puts "New decription: #{new_description}"
    puts ""
    c.update_column(:description, new_description)
  end
