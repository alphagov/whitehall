module SpecialistTopicHelper
  def stub_valid_specialist_topic
    stub_publishing_api_has_lookups({
      specialist_topic_base_path => specialist_topic_content_id,
      non_whitehall_document_base_path => non_whitehall_document_content_id,
      document_collection_base_path => document_collection_content_id,
    })

    stub_publishing_api_has_links({
      "content_id" => specialist_topic_content_id,
      "links" => level_two_topic_links,
    })

    stub_publishing_api_has_item(specialist_topic_content_item)
    stub_publishing_api_has_item(non_whitehall_document_content_item)
    stub_publishing_api_has_item(document_collection_content_item)
  end

  def stub_level_one_specialist_topic
    stub_publishing_api_has_lookups({
      specialist_topic_base_path => specialist_topic_content_id,
    })

    stub_publishing_api_has_links({
      "content_id" => specialist_topic_content_id,
      "links" => {},
    })

    stub_publishing_api_has_item(specialist_topic_content_item.deep_merge("links" => {}))
  end

  def stub_uncurated_specialist_topic
    stub_publishing_api_has_lookups({
      specialist_topic_base_path => specialist_topic_content_id,
    })

    stub_publishing_api_has_links({
      "content_id" => specialist_topic_content_id,
      "links" => level_two_topic_links,
    })

    stub_publishing_api_has_item(specialist_topic_content_item.deep_merge("details" => {}))
  end

  def specialist_topic_base_path
    "/topic/benefits-credits/child-benefit"
  end

  def specialist_topic_content_id
    "cc9eb8ab-7701-43a7-a66d-bdc5046224c0"
  end

  def specialist_topic_title
    "Child Benefit"
  end

  def specialist_topic_description
    "List of information about Child Benefit."
  end

  def whitehall_document_content_id
    "aed2cee3-7ca8-4f00-ab17-9193fff516ae"
  end

  def non_whitehall_document_content_id
    "0e1de8f1-9909-4e45-a6a3-bffe95470275"
  end

  def non_whitehall_document_base_path
    "/i-am-not-a-whitehall-document"
  end

  def non_whitehall_document_content_item
    { "title": "I am not a whitehall document",
      "base_path": non_whitehall_document_base_path,
      "content_id": non_whitehall_document_content_id,
      "document_type": "guide",
      "publishing_app": "publisher" }
  end

  def document_collection_content_id
    "10e436e5-26e0-4462-913f-9a497f7e793e"
  end

  def document_collection_base_path
    "/government/collections/i_am_document_collection"
  end

  def document_collection_content_item
    { "title": "I am a document collection",
      "base_path": document_collection_base_path,
      "content_id": document_collection_content_id,
      "document_type": "document_collection",
      "publishing_app": "whitehall" }
  end

  def specialist_topic_content_item
    {
      "base_path": specialist_topic_base_path,
      "content_id": specialist_topic_content_id,
      "document_type": "topic",
      "first_published_at": "2015-08-11T15:09:55.000+00:00",
      "schema_name": "topic",
      "title": specialist_topic_title,
      "links": level_two_topic_links,
      "description": specialist_topic_description,
      "details": {
        "groups": [
          {
            "name": "How to claim",
            "content_ids": [whitehall_document_content_id],
          },
          {
            "name": "Payments",
            "content_ids": [non_whitehall_document_content_id],
          },
          {
            "name": "Report changes",
            "content_ids": [document_collection_content_id],
          },
        ],
        "internal_name": "Benefits / Child Benefit",
      },
    }
  end

  def level_two_topic_links
    {
      "parent": [
        {
          "content_id": "4505d908-89f2-4322-956b-29ac243c608b",
          "title": "Benefits",
        },
      ],
    }
  end

  def level_one_specialist_topic_base_path
    "/topic/benefits-credits"
  end

  def level_one_specialist_topic_content_id
    "5fe781fb-7631-11e4-a3cb-005056011aef"
  end

  def level_one_specialist_topic_content_item
    specialist_topic_content_item[:base_path] = level_one_specialist_topic_base_path
    specialist_topic_content_item[:content_id] = level_one_specialist_topic_content_id
    specialist_topic_content_item.merge(links: {})
  end

  def uncurated_specialist_topic_base_path
    "/topic/i-am-an-a-to-z"
  end

  def uncurated_specialist_topic_content_id
    "e2644b6d-2c90-47e3-89b7-bf69be25465b"
  end

  def uncurated_specialist_topic_content_item
    specialist_topic_content_item[:base_path] = uncurated_specialist_topic_base_path
    specialist_topic_content_item[:content_id] = uncurated_specialist_topic_content_id
    specialist_topic_content_item.merge(details: {})
  end
end
