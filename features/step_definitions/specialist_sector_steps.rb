Given(/^there are some specialist sectors$/) do
  stub_specialist_sectors
end

When(/^I start editing a draft document$/) do
  begin_drafting_publication(title: 'A Specialist Publication')
end

Then(/^I can tag it to some specialist sectors$/) do
  select_specialist_sectors_in_form
  save_document
  assert_specialist_sectors_were_saved
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

  content_store_has_item(document_base_path, document_content_item)
end

Then(/^I should see the specialist sub\-sector and its parent sector$/) do
  header = find("article header")
  assert header.has_content?("Top Level Topic")
  assert header.has_css?('dd', text: "Topic 1 and Topic 2")
end
