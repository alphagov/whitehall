auto_redirects_with_non_govuk_url = Unpublishing.where(redirect: true).
                                       where("alternative_url NOT LIKE ? AND alternative_url NOT LIKE ?",
                                        'https://www.gov.uk%', 'http://www.dev.gov.uk%')
number = auto_redirects_with_non_govuk_url.count

puts "Fixing auto-redirects for non-GOVUK urls"
auto_redirects_with_non_govuk_url.each do |unpublishing|
  puts "ID: #{unpublishing.id}, URL: #{unpublishing.alternative_url}"
  unpublishing.unpublishing_reason_id = UnpublishingReason::PublishedInError.id
  unpublishing.redirect = false
  unpublishing.save(validate: false)
end
puts "#{number} unpublishings that no longer auto-redirect"
