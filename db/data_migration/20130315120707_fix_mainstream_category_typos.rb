controls = MainstreamCategory.where(slug: 'import-and-export-controls').first
controls.update_column(:description, 'Which goods are controlled and how to get licences for them; the UK Strategic Export Control Lists; dealing with the Export Control Organisation (ECO).')

procedures = MainstreamCategory.where(slug: 'import-and-export-procedures').first
procedures.update_column(:description, 'Customs declarations and documentation, dealing with HM Revenue & Customs (HMRC), using transit and processing systems, obtaining duty relief.')
