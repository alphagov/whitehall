Given("A user exists with uuid {string}") do |uuid|
  @user_from_signon = build(
    :signon_user,
    uid: uuid,
    name: "John Doe",
    email: "john@doe.com",
    organisation: build(:signon_user_organisation, content_id: "456", name: "User's Org", slug: "users-org"),
  )

  stub_request(:get, "#{Plek.find('signon', external: true)}/api/users")
    .with(query: { uuids: [uuid] })
    .to_return(body: [@user_from_signon].to_json)
end

When("I visit the user page for uuid {string}") do |uuid|
  visit content_block_manager.content_block_manager_user_path(uuid)
end

Then("I should see the details for that user") do
  expect(page).to have_selector("h1", text: @user_from_signon.name)
  expect(page).to have_selector(".govuk-summary-list__value", text: @user_from_signon.name)
  expect(page).to have_selector(".govuk-summary-list__value", text: @user_from_signon.email)
  expect(page).to have_selector(".govuk-summary-list__value", text: @user_from_signon.organisation.name)
end
