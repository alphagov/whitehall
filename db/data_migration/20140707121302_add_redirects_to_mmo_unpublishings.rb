collections = [
  ["fishing-vessel-licences-10-metre-and-under-vessels", "/understand-your-fishing-vessel-licence"],
  ["fishing-vessel-licences-over-10-metre-vessels", "/understand-your-fishing-vessel-licence"],
  ["marine-conservation-byelaws", "/marine-conservation-byelaws"],
]

detailed_guides = [
  ["east-marine-plan-areas", "/east-inshore-and-east-offshore-marine-plan-areas"],
  ["get-a-fishing-vessel-licence-mussel-seed", "/get-a-fishing-vessel-licence-vessels-over-10-metres"],
  ["get-an-oil-spill-treatment-product-approved", "/clean-an-oil-spill-at-sea-and-get-oil-spill-treatments-approved"],
  ["get-involved-in-marine-planning", "/marine-plans-development"],
  ["how-a-marine-plan-is-made", "/marine-plans-development"],
  ["how-to-clean-an-oil-spill-at-sea", "/clean-an-oil-spill-at-sea-and-get-oil-spill-treatments-approved"],
  ["make-a-european-fisheries-fund-claim", "/apply-for-a-european-fisheries-fund-grant"],
  ["make-changes-to-your-fishing-vessel-licence-combine-and-separate-licences", "/government/publications/changes-to-fishing-vessel-licensing-arrangements"],
  ["make-changes-to-your-fishing-vessel-licence", "/government/publications/changes-to-fishing-vessel-licensing-arrangements"],
  ["marine-licensing-additional-information-for-dredging-applications", "/apply-to-dredge-and-extract-aggregates"],
  ["marine-licensing-disposing-waste-at-sea", "/apply-to-construct-on-remove-from-and-dispose-to-the-seabed"],
  ["marine-licensing-diving", "/apply-to-construct-on-remove-from-and-dispose-to-the-seabed"],
  ["marine-licensing-dredging", "/apply-to-dredge-and-extract-aggregates"],
  ["marine-licensing-emergency-application", "/marine-licensing-application-process"],
  ["marine-licensing-exemptions", "/marine-licensing-application-process"],
  ["marine-licensing-fast-track-application-process", "/marine-licensing-application-process"],
  ["marine-licensing-local-or-regional-dredging-conditions", "/apply-to-dredge-and-extract-aggregates"],
  ["marine-licensing-maintenance-activities", "/apply-to-dredge-and-extract-aggregates"],
  ["marine-licensing-marker-buoys-and-posts", "/apply-to-construct-on-remove-from-and-dispose-to-the-seabed"],
  ["marine-licensing-minor-removals", "/apply-to-construct-on-remove-from-and-dispose-to-the-seabed"],
  ["marine-licensing-sampling-and-sediment-analysis", "/apply-to-take-samples-analyse-sediment-and-make-minor-removals"],
  ["marine-licensing-scaffolding-and-ladders", "/apply-to-construct-on-remove-from-and-dispose-to-the-seabed"],
  ["marine-licensing-scientific-sampling", "/apply-to-take-samples-analyse-sediment-and-make-minor-removals"],
  ["marine-wildlife-licence", "/understand-marine-wildlife-licences-and-report-an-incident"],
  ["report-a-wildlife-incident", "/understand-marine-wildlife-licences-and-report-an-incident"],
  ["report-and-respond-to-a-marine-pollution-incident", "/clean-an-oil-spill-at-sea-and-get-oil-spill-treatments-approved"],
  ["south-marine-plan-areas", "/south-inshore-and-south-offshore-marine-plan-areas"],
]

publications = [
  ["category-c-annexes", "/understand-your-fishing-vessel-licence"],
  ["category-c-conditions-and-schedule", "/understand-your-fishing-vessel-licence"],
  ["deep-sea-species-annexes", "/understand-your-fishing-vessel-licence"],
  ["deep-sea-species-conditions-and-schedule", "/understand-your-fishing-vessel-licence"],
  ["handline-mackerel-conditions-and-schedule", "/understand-your-fishing-vessel-licence"],
  ["non-sector-capped-licences", "/understand-your-fishing-vessel-licence"],
  ["non-sector-uncapped-licences", "/understand-your-fishing-vessel-licence"],
  ["sector-annexes", "/understand-your-fishing-vessel-licence"],
  ["sector-conditions-and-schedule", "/understand-your-fishing-vessel-licence"],
  ["thames-and-blackwater-conditions-and-schedule", "/understand-your-fishing-vessel-licence"],
]

collections.each do |(slug, redirect)|
  unpublishing = Unpublishing.where(slug: slug, document_type: "DocumentCollection").first

  unpublishing.redirect = true
  unpublishing.alternative_url = "#{Whitehall.public_protocol}://#{Whitehall.public_host}#{redirect}"
  unpublishing.save(validate: false)

  puts "#{slug} -> #{redirect}"
end

detailed_guides.each do |(slug, redirect)|
  unpublishing = Unpublishing.where(slug: slug, document_type: "DetailedGuide").first

  unpublishing.redirect = true
  unpublishing.alternative_url = "#{Whitehall.public_protocol}://#{Whitehall.public_host}#{redirect}"
  unpublishing.save(validate: false)

  puts "#{slug} -> #{redirect}"
end

publications.each do |(slug, redirect)|
  unpublishing = Unpublishing.where(slug: slug, document_type: "Publication").first

  unpublishing.redirect = true
  unpublishing.alternative_url = "#{Whitehall.public_protocol}://#{Whitehall.public_host}#{redirect}"
  unpublishing.save(validate: false)

  puts "#{slug} -> #{redirect}"
end
