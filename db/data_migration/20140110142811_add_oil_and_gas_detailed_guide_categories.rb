def oil_and_gas_topics
  [
    { slug: "carbon-capture-and-storage", title: "Carbon capture and storage" },
    { slug: "environment-reporting-and-regulation", title: "Environment reporting and regulation" },
    { slug: "exploration-and-development", title: "Exploration and development" },
    { slug: "fields-and-wells", title: "Fields and wells" },
    { slug: "finance-and-taxation", title: "Finance and taxation" },
    { slug: "infrastructure-and-decommissioning", title: "Infrastructure and decommissioning" },
    { slug: "licensing", title: "Licensing" },
    { slug: "onshore-oil-and-gas", title: "Onshore oil and gas" }
  ]
end

def slug_for_topic(topic)
  "industry-sector-oil-and-gas-#{topic[:slug]}"
end

oil_and_gas_topics.each do |topic|
  MainstreamCategory.create!(
    slug: slug_for_topic(topic),
    title: "Oil and gas: #{topic[:title]}",
    parent_title: "Industry sector: Oil and gas",
    parent_tag: "oil-and-gas"
  )
end
