edition = Document.find_by(slug: "25000-spend").editions.find_by(change_note: "Updated with HMT spend greater than £25,000: February 2016")

edition.update_attributes(change_note: "Updated with HMT spend greater than £25,000: February 2017")
