if royal_mint = Organisation.find_by_name("Royal Mint")
  $stderr.print "Updating 'Royal Mint' url to 'http://www.royalmint.com/'..."
  royal_mint.update_attributes!(url: "http://www.royalmint.com/")
  $stderr.puts "[done]"
end

Organisation.all.each do |organisation|
  unless organisation.valid? && organisation.errors[:url].empty?
    $stderr.print "Updating '#{organisation.name}' url to nil..."
    organisation.update_attributes!(url: nil)
    $stderr.puts "[done]"
  end
end
