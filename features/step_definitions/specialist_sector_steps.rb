Given(/^there are some specialist sectors$/) do
  stub_specialist_sectors
end

When(/^I start editing a draft document$/) do
  begin_drafting_publication(title: "A Specialist Publication")
end

Then(/^I can tag it to some specialist sectors$/) do
  primary_select = using_design_system? ? "edition[primary_specialist_sector_tag]" : "Primary specialist topic tag"
  secondary_select = using_design_system? ? "edition[secondary_specialist_sector_tags][]" : "Additional specialist topics"

  select "Oil and Gas: Wells", from: primary_select
  select "Oil and Gas: Offshore", from: secondary_select
  select "Oil and Gas: Fields", from: secondary_select
  select "Oil and Gas: Distillation (draft)", from: secondary_select

  click_button using_design_system? ? "Update specialist topics" : "Save"

  expect(page).to have_selector(".flash.notice")

  click_on "Edit draft"
  check "Applies to all UK nations"
  click_on "Save and continue"
  click_on "Update and review specialist topic tags"

  expect("WELLS").to eq(find_field(primary_select).value)
  expect(%w[OFFSHORE FIELDS DISTILL].to_set)
    .to eq(find_field(secondary_select).value.to_set)
end

Given(/^there is a document tagged to specialist sectors$/) do
  @document = create(:published_publication, :guidance)
  document_base_path = PublishingApiPresenters.presenter_for(@document).content[:base_path]
  parent_base_path = "/parent-topic"

  document_content_item = content_item_for_base_path(document_base_path)
                            .merge(
                              "links" => {
                                "parent" => [
                                  {
                                    "base_path" => parent_base_path,
                                    "links" => {
                                      "parent" => [
                                        {
                                          "title" => "Top Level Topic",
                                          "web_url" => "http://gov.uk/top-level-topic",
                                        },
                                      ],
                                    },
                                  },
                                ],
                                "topics" => [
                                  {
                                    "title" => "Topic 1",
                                  },
                                  {
                                    "title" => "Topic 2",
                                  },
                                ],
                              },
                            )

  stub_content_store_has_item(document_base_path, document_content_item)
end

Then(/^I should see the specialist sub-sector and its parent sector$/) do
  within "article header" do
    expect(page).to have_content("Top Level Topic")
    expect(page).to have_selector("dd", text: "Topic 1 and Topic 2")
  end
end
