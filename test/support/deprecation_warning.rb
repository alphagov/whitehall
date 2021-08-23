# Chaining multiple scopes that use the same column is deprecated.
# We are seeing the warning:
##########
# DEPRECATION WARNING: Merging (`editions`.`state` != 'deleted') and (`editions`.`state` IN (?, ?))
# no longer maintain both conditions, and will be replaced by the latter in Rails 6.2.
# To migrate to Rails 6.2's behavior, use `relation.merge(other, rewhere: true)
#########
# This is because we have a default scope on the Edition model:
# `default_scope -> { where(arel_table[:state].not_eq("deleted")) }`
# So for example, Edition.first.force_published equates to
# Edition.where.not(state:"deleted").where(state: "published", force_published: true)
# and as of Rails 6.2 only the second condition will be maintained.
# Silencing temporarily because only using the second condition is fine and
# adding the recommended code breaks everything.

rewhere_warning = "no longer maintain both conditions, and will be replaced by "\
"the latter in Rails 6.2. To migrate to Rails 6.2's behavior, "\
"use `relation.merge(other, rewhere: true)`."
ActiveSupport::Deprecation.behavior = lambda do |msg, _stack|
  unless msg.include?(rewhere_warning)
    ActiveSupport::Deprecation.behavior = :stderr
  end
end
