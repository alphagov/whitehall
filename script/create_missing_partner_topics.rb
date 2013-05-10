require 'csv'

CSV.read(ARGV[0], headers: true, header_converters: :symbol).each_with_index do |row, i|
  url = row[0]
  parts = url.sub('https://www.gov.uk/government/', '').split('/')
  if parts.first == 'policies'
    alert = EmailSignup::Alert.new(policy: parts[1])
    puts "#{url} => #{EmailSignup::GovUkDeliveryRedirectUrlExtractor.new(alert).redirect_url}"
    # puts EmailSignup::FeedUrlExtractor.new(alert).feed_url
  elsif parts.first.include? 'feed'
    parsed = Rack::Utils.parse_nested_query(parts.first.split('?')[1])
    alert = nil
    if parsed['topics']
      alert = EmailSignup::Alert.new(topic: parsed['topics'].first, document_type: 'all')
    elsif parsed['departments']
      alert = EmailSignup::Alert.new(organisation: parsed['departments'].first, document_type: 'all')
    end
    if alert
      puts "#{url} => #{EmailSignup::GovUkDeliveryRedirectUrlExtractor.new(alert).redirect_url}"
      # puts EmailSignup::FeedUrlExtractor.new(alert).feed_url
    else
      puts "#{url} => Can't be topic-ified (parsed as:#{parsed})"
    end
  end
end
