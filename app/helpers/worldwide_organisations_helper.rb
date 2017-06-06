module WorldwideOrganisationsHelper
  include ActionDispatch::Routing::PolymorphicRoutes

  def worldwide_organisation_path(worldwide_organisation, options = {})
    if ab_test_helper.is_under_test?(worldwide_organisation)
      worldwide_organisation_url(
        worldwide_organisation,
        options.merge(only_path: true)
      )
    else
      super
    end
  end

  def worldwide_organisation_url(worldwide_organisation, options = {})
    if ab_test_helper.is_under_test?(worldwide_organisation)
      location = ab_test_helper.location_for(worldwide_organisation)
      location_path_or_url = world_location_url(location, options)
      # this is 'wrong' but URI::join needs a host which we may or may not have
      # so for the purposes of the AB test this seems pragmatic and simple
      # it will run on linux and join on /
      File.join(location_path_or_url, worldwide_organisation.slug)
    else
      super
    end
  end

private

  def ab_test_helper
    @ab_test_helper ||= WorldwideAbTestHelper.new
  end
end
