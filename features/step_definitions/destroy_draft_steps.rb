When("I discard the draft publication") do
  design_system_layout = @user.can_preview_design_system? || @user.can_preview_second_release?

  @publication = Publication.last
  visit confirm_destroy_admin_edition_path(@publication)
  if design_system_layout
    click_on "Delete"
  else
    click_on "Discard"
  end
end

Then("the publication is deleted") do
  @publication = Publication.last
  expect(@publication).to be_nil
end
