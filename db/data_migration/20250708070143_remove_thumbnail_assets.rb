# **SCRIPT TO CHECK WHICH ASSETS TO DELETE**
#
# # 0.  Get the list of enum strings that ARE valid
# valid_variants = Asset.defined_enums["variant"].keys
# # => ["original", "s960", "s712", …]

# # Grab every Asset whose stored variant is NOT one of those
# invalid_assets = Asset.where.not(variant: valid_variants)
# total = invalid_assets.count
# # Split them on the filename pattern
# non_matching = invalid_assets.where.not("filename REGEXP ?", '^thumbnail_.*\\.png$')

# puts <<~MSG
#   --- Asset variant audit ---
#   Total records with 'variant' shown as nil: #{total}
#   Of those, filenames NOT matching thumbnail_*.png: #{non_matching.count}
#   IDs of the non-matching rows (safe-delete sanity check):
#   #{non_matching.pluck(:id).join(', ')}
# MSG
#
# **OUTPUT OF THE RUN**
#
# --- Asset variant audit ---
# Total records with 'variant' shown as nil: 782232
# Of those, filenames NOT matching thumbnail_*.png: 23
# IDs of the non-matching rows (safe-delete sanity check):
# 1048455, 1048463, 1048467, 1048469, 1048473, 1048475, 1048479, 1048481, 1048487, 1048491, 1048493, 1048497, 1048501, 1048507, 1048509, 1048511, 1049303, 1049639, 1050990, 1051019, 1051041, 1051043, 1751104
#
assets_to_look_at_later = [1_048_455, 1_048_463, 1_048_467, 1_048_469, 1_048_473, 1_048_475, 1_048_479, 1_048_481, 1_048_487, 1_048_491, 1_048_493, 1_048_497, 1_048_501, 1_048_507, 1_048_509, 1_048_511, 1_049_303, 1_049_639, 1_050_990, 1_051_019, 1_051_041, 1_051_043, 1_751_104]

valid_variants = Asset.defined_enums["variant"].keys

Asset.where.not(variant: valid_variants)
     .where("filename REGEXP ?", '^thumbnail_.*\\.png$')
     .where.not(id: assets_to_look_at_later)
     .delete_all
