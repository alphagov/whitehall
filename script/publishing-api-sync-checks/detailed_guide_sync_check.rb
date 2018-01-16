detailed_guides = DetailedGuide.where(state: %w{published draft withdrawn})
check = DataHygiene::PublishingApiSyncCheck.new(detailed_guides)

check.add_expectation("format") do |content_store_payload, _|
  content_store_payload["format"] == "detailed_guide"
end

check.add_expectation("base_path") do |content_store_payload, record|
  content_store_payload["base_path"] == record.search_link
end

check.add_expectation("title") do |content_store_payload, record|
  content_store_payload["title"] == record.title
end

check.add_expectation("related_guides") do |content_store_payload, record|
  if record.state == 'draft'
    # Draft items currently use the same `LinkSet` as the published item. This means that if somebody
    # publishes a draft with additional (or removed) linked items, the content-store won't reflect this.
    # Until this is resolved, we won't run this check for draft items.
    true
  else
    payload_ids = content_store_payload["links"]["related_guides"].map { |rg| rg["content_id"] }.to_set
    payload_ids == record.related_detailed_guide_content_ids.to_set
  end
end

check.add_expectation("related_mainstream") do |content_store_payload, record|
  if record.state == 'draft'
    # Draft items currently use the same `LinkSet` as the published item. This means that if somebody
    # publishes a draft with additional (or removed) linked items, the content-store won't reflect this.
    # Until this is resolved, we won't run this check for draft items.
    true
  else
    payload_rm_content_ids = content_store_payload["links"]["related_mainstream"].map { |rg| rg["content_id"] }.to_set
    payload_rm_content_ids == record.related_mainstream.to_set
  end
end

check.add_expectation("political") do |content_store_payload, record|
  record.political? == content_store_payload["details"]["political"]
end

check.add_expectation("government") do |content_store_payload, record|
  gov = record.government
  record_government = {
    "title" => gov.name,
    "slug" => gov.slug,
    "current" => gov.current?
  }

  payload_government = content_store_payload["details"]["government"]

  record_government == payload_government
end

check.add_expectation("withdrawn_notice") do |content_store_payload, record|
  if record.withdrawn?
    record_withdrawn_notice = {
      "explanation" => Whitehall::GovspeakRenderer.new.govspeak_to_html(record.unpublishing.explanation),
      "withdrawn_at" => record.updated_at
    }

    payload_withdrawn_notice = content_store_payload["details"]["withdrawn_notice"]

    record_withdrawn_notice == payload_withdrawn_notice
  else
    true
  end
end

check.add_expectation("national_applicability") do |content_store_payload, record|
  if record.nation_inapplicabilities.any?
    record.national_applicability.to_json == content_store_payload["details"]["national_applicability"].to_json
  else
    true
  end
end

check.add_expectation("policy_areas") do |content_store_payload, record|
  policy_area_ids = (record.try(:topics) || []).map(&:content_id).to_set
  content_store_policy_area_ids = content_store_payload["links"]["policy_areas"]
    .map { |policy_area| policy_area["content_id"] }
    .to_set

  policy_area_ids == content_store_policy_area_ids
end

check.add_expectation("related_policies") do |content_store_payload, record|
  related_policy_ids = (record.try(:policy_content_ids) || []).to_set
  content_store_related_policy_ids = content_store_payload["links"]["related_policies"]
    .map { |related_policy| related_policy["content_id"] }
    .to_set

  related_policy_ids == content_store_related_policy_ids
end

check.perform
