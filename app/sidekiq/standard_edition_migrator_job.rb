require "diffy"
require "pp"

class StandardEditionMigratorJob < JobBase
  # Don't retry this job if it fails, because it's typically all
  # ‘internal’ – so it won’t fail because a third-party API is down,
  # and any failure is unlikely to resolve itself on a retry.
  sidekiq_options queue: "standard_edition_migration", retry: 0

  def perform(record_id, args)
    compare_payloads = args["compare_payloads"]
    model_class_name = args["model_class"]

    legacy_record = model_class_name.constantize.find(record_id)
    recipe = StandardEditionMigrator.recipe_for(legacy_record)

    ActiveRecord::Base.transaction do
      initialized_recipe = recipe.new(legacy_record)

      preview_migration(legacy_record, recipe, raise_if_payloads_diverge: compare_payloads)
      # TODO: add a comparison check guardrail here ^

      initialized_recipe.save_built_edition!
      # TODO: add a comparison guardrail here, i.e. if the payload of the saved thing doesn't match the payload
      # of the preview, raise an error ^
    end
  end
end
