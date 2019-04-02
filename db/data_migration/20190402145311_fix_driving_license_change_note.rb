original_change_note = "UK driving licence holders now need a 1969 IDP to drive in Albania, Armenia, Azerbaijan, Bahamas, Bahrain, Belarus, Bosnia and Herzegovina, Brazil, Cape Verde, Central African Republic, Cote d’Ivoire, Cuba, Democratic Republic of Congo, Eswatini, French Polynesia, Georgia, Guyana, Iran, Iraq, Israel, Kazakhstan, Kenya, Kuwait, Kyrgyzstan, Liberia, Moldova, Monaco, Mongolia, Montenegro, Morocco, Niger, North Macedonia, Pakistan, Peru, Philippines, Qatar, Russian Federation, San Marino, Saudi Arabia, Senegal, Serbia, Seychelles, South Africa, Tajikistan, Tunisia, Turkey, Turkmenistan, Ukraine, United Arab Emirates, Uruguay, Uzbekistan, Vietnam, Zimbabwe."
new_change_note = "UK driving licence holders now need a 1968 IDP to drive in Albania, Armenia, Azerbaijan, Bahamas, Bahrain, Belarus, Bosnia and Herzegovina, Brazil, Central African Republic, Cote d’Ivoire, Cuba, Democratic Republic of Congo, Eswatini, French Polynesia, Georgia, Guyana, Iran, Iraq, Israel, Kazakhstan, Kenya, Kuwait, Kyrgyzstan, Liberia, Moldova, Monaco, Mongolia, Montenegro, Morocco, Niger, North Macedonia, Pakistan, Peru, Philippines, Qatar, Russian Federation, San Marino, Saudi Arabia, Senegal, Serbia, Seychelles, South Africa, Tajikistan, Tunisia, Turkey, Turkmenistan, Ukraine, United Arab Emirates, Uruguay, Uzbekistan, Vietnam, Zimbabwe."

document = Document.find_by(slug: "international-driving-permits-for-uk-drivers-from-28-march-2019")

edition = document.editions.find_by(change_note: original_change_note)

edition.update_column(:change_note, new_change_note)

PublishingApiDocumentRepublishingWorker.perform_async(document.id)
