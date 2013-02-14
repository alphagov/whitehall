gds = User.find_by_name("GDS Inside Government Team")
raise "Cannot find admin user to unpublish with" unless gds

Document.find_by_slug("non-native-fish").update_column(:slug, "non-native-fish-and-shellfish")
Document.find_by_slug("importing-live-fish-molluscs-and-crustacea").update_column(:slug, "importing-and-exporting-live-fish-molluscs-and-crustacea")

Document.find_by_slug("non-native-crayfish-and-lobster-deposits").latest_edition.unpublish_as(gds)
