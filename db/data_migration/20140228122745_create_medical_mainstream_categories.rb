categories = [
  {
    slug: "medicinal-and-medical-device-licenses",
    title: "Medicinal and medical device licences",
    parent_title: "Licences and licence applications",
    parent_tag: "business/licences",
    description: "Apply for licences to manufacture, supply, and import or export medicines, herbal medicines and medical devices."
  }, {
    slug: "medicinal-and-medical-device-safety-and-regulation",
    title: "Medicinal and medical device safety and regulation",
    parent_title: "Manufacturing",
    parent_tag: "business/manufacturing",
    description: "Guidance on the safe manufacture, storage or sale of medicines and medical devices, including drug safety and reporting requirements."
  }, {
    slug: "clinical-trials",
    title: "Clinical Trials",
    parent_title: "Scientific research and development",
    parent_tag: "business/science",
    description: "Guidance on the rules and regulations for conducting clinical trials of medicines and medical devices."
  }
]

categories.each { |category| MainstreamCategory.create!(category) }
