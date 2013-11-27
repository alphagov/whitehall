scope = SupportingPage.where(alternative_format_provider_id: nil)
puts "Restorting alternative format provider for #{scope.count} supporting page(s)"

scope.includes(:related_policies).find_each do |sp|
  sp.update_attribute(:alternative_format_provider_id, sp.related_policies.first.alternative_format_provider_id)
  printf '.'
end
