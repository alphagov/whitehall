# These WLNA all have 'submitted' editions with an unupblishing which has a reason of 4
# (consolidated) and an alternative url. They are missing the relevant redirect in the content
# store. Fix it.

redirects = {
  "5fe5e9d9-7631-11e4-a3cb-005056011aef": "https://www.gov.uk/government/news/uk-attracts-highest-levels-of-inward-investment-on-record",
  "04343ee5-1013-423d-89c5-e190dba16aad": "https://www.gov.uk/government/speeches/british-ambassador-to-drc-speaks-at-international-anti-corruption-day"
}

redirects.each do |content_id, redirect_url|
  PublishingApiRedirectWorker.perform_async(content_id, redirect_url, :en, true)
end
