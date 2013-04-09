class GovUkDeliveryNotificationJob < Struct.new(:id)

  def perform
    Whitehall.govuk_delivery_client.notify(edition.govuk_delivery_tags, edition.title, email_body)
  end

  def edition
    @edition ||= Edition.find(id)
  end

  def edition_url
    edition.document_url(edition, host: Whitehall.public_host)
  end

  def email_body
%Q(<div class="rss_item" style="margin-bottom: 2em;">
  <div class="rss_title" style="font-size: 120%; margin: 0 0 0.3em; padding: 0;">
    #{'Updated' if change_note}
    <a href="#{edition_url}" style="font-weight: bold; ">#{edition.title}</a>
  </div>
  #{public_date_html}
  <br />
  <div class="rss_description" style="margin: 0 0 0.3em; padding: 0;">#{change_note || edition.summary}</div>
</div>)
  end

  def public_date
    edition.notification_date.try(:strftime, '%e %B, %Y at %I:%M%P')
  end

  def change_note
    if edition.document.change_history.length > 1
      edition.document.change_history.first.note
    end
  end

  def public_date_html
    if public_date
      %Q(<div class="rss_pub_date" style="font-size: 90%; margin: 0 0 0.3em; padding: 0; color: #666666; font-style: italic;">#{public_date}</div>)
    end
  end
end
