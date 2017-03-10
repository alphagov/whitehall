# These policies don't exist in policy publisher
# so disassociate them with speeches.
deleted_policy_content_ids = %w(
  5c8eab14-7631-11e4-a3cb-005056011aef
  5e35d75c-7631-11e4-a3cb-005056011aef
  5d376d68-7631-11e4-a3cb-005056011aef
  5f1ab94f-7631-11e4-a3cb-005056011aef
  5f1b09e6-7631-11e4-a3cb-005056011aef
  5f52615a-7631-11e4-a3cb-005056011aef
  3c04de88-9e4a-4ebb-bdc9-ef5946db17b9
)

EditionPolicy.destroy_all(policy_content_id: deleted_policy_content_ids)

# This draft only Speech has a different content id to that stored
# in the publishing api, it's easier to update the document in Whitehall.
doc = Document.find(313611)
doc.update!(content_id: "6778ffde-8d6c-43a2-ae74-2b255183b2fd")
