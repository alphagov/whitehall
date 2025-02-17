# This helper overrides Rails' generated `component_doc_path` method
# that is used in the govuk_publishing_components gem:
# https://github.com/alphagov/govuk_publishing_components/blob/a4c1e2d246249dc7d4e659a9a58c3fdf4a85d13e/app/controllers/govuk_publishing_components/component_guide_controller.rb#L168
#
# Without it, something in Whitehall overrides it to the
# `/assets/whitehall` assets prefix path, so all of the links under
#  `/component-guide/` are broken.
#
# This override really shouldn't be needed, but we've tried comparing
# and contrasting with other apps where the override isn't needed
# (e.g. Specialist Publisher) and no matter what we delete, edit or
# comment out, the links continue to be broken. In the grand scheme
# of things, this little override solves the problem pretty succinctly.
module ComponentGuideHelper
  def component_doc_path(component_id)
    "/component-guide/#{component_id}"
  end
end
