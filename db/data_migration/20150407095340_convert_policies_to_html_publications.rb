module PolicyMigrationHelpers
  def self.build_html_attachment_body(policy, url_maker, alternative_format_provider)
    callout = %|
$CTA
This is a copy of a document that stated a policy of the 2010 to 2015 Conservative and Liberal Democrat coalition government.
The previous URL of this page was [#{url_maker.public_document_url(policy)}](#{url_maker.public_document_path(policy)})
Current policies can be found at the GOV.UK [policies list](/government/policies).
$CTA

|

    combined_body = callout + policy.body

    supporting_pages = policy.supporting_pages.published
    supporting_pages.each_with_index do |supporting_page, index|
      combined_body += extract_supporting_page(supporting_page, index, alternative_format_provider)
    end

    return combined_body
  end

  def self.copy_associations!(policy, policy_paper)
    [
      :lead_organisations,
      :supporting_organisations,
      :topics,
      :topical_events,
      :nation_inapplicabilities,
      :role_appointments,
      :fact_check_requests,
      :world_locations,
      :related_documents,
      :specialist_sectors,
    ].each do |association|
      policy_paper.send("#{association}=".to_sym, policy.send(association))
    end
  end

  def self.extract_supporting_page(supporting_page, index, alternative_format_provider)
    appendix_title = "Appendix #{index+1}: #{supporting_page.title}"

    puts "-- Adding supporting page ##{supporting_page.id}: as #{appendix_title}"

    sp_body = %|

###{appendix_title}

$CTA
This was a supporting detail page of the main policy document.
$CTA

#{supporting_page.body.gsub(/^(\s*[#]{2,})/, '\1#')}
|

    sp_body.gsub(/\[InlineAttachment:([0-9]+)\]/) do
      if attachment = supporting_page.attachments[$1.to_i - 1]
        "[#{attachment.title}](#{attachment.url})"
      else
        ""
      end
    end
  end
end

gds_user = User.find_by!(name: "GDS Inside Government Team")
url_maker = UrlMaker.new

Policy.published.each do |policy|
  puts %{Creating policy paper from policy ##{policy.id}}

  title = "2010 to 2015 Conservative and Liberal Democrat coalition policy: #{policy.title}"
  short_title = "2010 to 2015 coalition policy: #{policy.title}"

  supporting_pages = policy.supporting_pages.published

  alternative_format_provider = policy.lead_organisations.first

  html_attachment = HtmlAttachment.new(
    title: title,
    ordering: 0,
    govspeak_content: GovspeakContent.new(
      body: PolicyMigrationHelpers.build_html_attachment_body(policy, url_maker, alternative_format_provider),
      manually_numbered_headings: false,
    ),
  )

  policy_paper_body = "This policy paper shows the policy of the 2010 to 2015 Conservative and Liberal Democrat coalition government.

Find out about the [current government’s policies](/government/policies)."

  policy_paper = Publication.new(
    title: title,
    summary: policy.summary,
    body: policy_paper_body,
    publication_type_id: PublicationType::PolicyPaper.id,
    first_published_at: DateTime.new(2015, 3, 27, 6, 0, 0), # 6am, 27 March 2015
    political: true,
    creator: gds_user,
    alternative_format_provider: alternative_format_provider,
    document: Document.new(
      sluggable_string: short_title,
      content_id: SecureRandom.uuid
    ),
  )

  PolicyMigrationHelpers.copy_associations!(policy, policy_paper)

  if policy_paper.save

    policy_paper.attachments << html_attachment
    supporting_pages.map(&:attachments).flatten.uniq.each_with_index do |attachment, index|
      puts %{-- Adding attachment "#{attachment.html? ? 'HTML' : attachment.filename}"}

      existing_attachment = attachment.deep_clone

      # Reset attachment ordering, accounting for the HTML attachment
      # These have never been manually set for supporting pages,
      # so we don't need to worry about preserving order.
      existing_attachment.ordering = index + 1

      policy_paper.attachments << existing_attachment
    end

    puts %{Created policy paper ##{policy_paper.id} "#{policy_paper.title}" from policy ##{policy.id}}
  else
    policy_paper.errors.full_messages.each do |error|
      puts %{-- #{error}}

      puts %{---- #{policy_paper.body}} if error =~ /invalid formatting/

      if error =~ /Attachments/
        policy_paper.attachments.each do |attachment|
          puts %{---- #{attachment.errors.full_messages.join(',')}}
        end
      end
    end

    puts %{Failed to create policy paper from policy ##{policy.id} "#{policy_paper.title}"}
  end

  puts
end
