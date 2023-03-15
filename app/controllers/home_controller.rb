class HomeController < PublicFacingController
  layout "frontend"

  def how_government_works
    sitewide_setting = load_reshuffle_setting
    @is_during_reshuffle = sitewide_setting.on if sitewide_setting
    @prime_minister = MinisterialRole.find_by(slug: "prime-minister").current_person
    sorter = MinisterSorter.new
    @cabinet_minister_count = sorter.cabinet_ministers.count - 1 # subtract one to discount PM
    @other_minister_count = sorter.other_ministers.count
    @all_ministers_count = @cabinet_minister_count + @other_minister_count + 1 # add one to put the PM back in
    @ministerial_department_count = Organisation.listable.ministerial_departments.count
    @non_ministerial_department_count = Organisation.listable.non_ministerial_departments.count
    set_meta_description("In the UK, the Prime Minister leads the government with the support of the Cabinet and ministers. You can find out who runs government and how government is run, as well as learning about the history of government.")
  end
end
