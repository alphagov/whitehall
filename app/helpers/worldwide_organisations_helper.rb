module WorldwideOrganisationsHelper
  def worldwide_organisation_link_for_ab_test(worldwide_organisation, user_is_in_b_test_group)
    if ab_test_helper.is_under_test?(worldwide_organisation) && user_is_in_b_test_group
      b_url(worldwide_organisation)
    else
      worldwide_organisation_path(worldwide_organisation)
    end
  end

private

  def b_url(worldwide_organisation)
    location = ab_test_helper.location_for(worldwide_organisation)
    location_path_or_url = world_location_url(location)
    # this is 'wrong' but URI::join needs a host which we may or may not have
    # so for the purposes of the AB test this seems pragmatic and simple
    # it will run on linux and join on /
    File.join(location_path_or_url, worldwide_organisation.slug)
  end

  def ab_test_helper
    @ab_test_helper ||= WorldwideAbTestHelper.new
  end
end
