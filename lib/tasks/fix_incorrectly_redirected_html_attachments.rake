PATHS = %w[
  /government/publications/advice-for-company-directors-on-avoiding-cartel-infringements/3361136
  /government/publications/approval-of-mortgage-documentation/2670018
  /government/publications/charging-orders/1171071
  /government/publications/client-notification-income-or-assets-abroad/1907343
  /government/publications/companies-house-events-calendar/3697559
  /government/publications/company-registers/2187773
  /government/publications/compliance-checks-construction-industry-scheme-penalties-for-false-registration-ccfs41/2309200
  /government/publications/compliance-checks-information-about-the-general-anti-abuse-rule-ccfs34a/2414690
  /government/publications/developing-estates-registration-services-plot-sales-transfers-and-leases/1609908
  /government/publications/digital-economy-act-2017-part-5-codes-of-practice/3984213
  /government/publications/digital-economy-act-2017-part-5-codes-of-practice/3984214
  /government/publications/digital-economy-act-2017-part-5-codes-of-practice/3984215
  /government/publications/digital-economy-act-2017-part-5-codes-of-practice/3984216
  /government/publications/discharge-of-charges/1506337
  /government/publications/evidence-of-identity-conveyancers/1409213
  /government/publications/first-registrations/1640442
  /government/publications/first-registrations/3054152
  /government/publications/general-anti-abuse-rule-and-pooling-notices-ccfs35/2605460
  /government/publications/genuine-hmrc-contact-and-recognising-phishing-emails/1559584
  /government/publications/genuine-hmrc-contact-and-recognising-phishing-emails/3059440
  /government/publications/hm-land-registry-customer-charter/3002359
  /government/publications/hm-land-registry-welsh-language-scheme/2042633
  /government/publications/how-hm-revenue-and-customs-keeps-you-safe-online/829987
  /government/publications/islamic-financing/1170996
  /government/publications/islamic-financing/2952497
  /government/publications/land-registry-plans-boundaries/1584179
  /government/publications/land-registrys-welsh-language-scheme/2950255
  /government/publications/making-tax-digital-for-business-stakeholder-communications-pack/3652618
  /government/publications/opg-corporate-framework/3004776
  /government/publications/price-fixing-guidance-for-online-sellers/3357935
  /government/publications/reporting-fraud-about-a-company-to-companies-house/1656571
  /government/publications/restricting-disclosure-of-your-address/2613473
  /government/publications/searches-of-the-index-of-proprietors-names/1171052
  /government/publications/setting-prices-on-online-travel-agents-advice-for-hotels/3361045
  /government/publications/uk-governments-preparations-for-a-no-deal-scenario/2901058
  /government/publications/uk-house-price-index-summary-august-2017/2342020
  /government/publications/uk-house-price-index-summary-august-2018/3000373
  /government/publications/uk-house-price-index-summary-december-2017/2522030
  /government/publications/uk-house-price-index-summary-february-2018/2636304
  /government/publications/uk-house-price-index-summary-january-2018/2608784
  /government/publications/uk-house-price-index-summary-july-2017/2267839
  /government/publications/uk-house-price-index-summary-july-2018/2926183
  /government/publications/uk-house-price-index-summary-june-2017/2210984
  /government/publications/uk-house-price-index-summary-june-2018/2919859
  /government/publications/uk-house-price-index-summary-may-2017/2183102
  /government/publications/uk-house-price-index-summary-november-2016/1890737
  /government/publications/uk-house-price-index-summary-october-2016/1847977
  /government/publications/uk-house-price-index-wales-august-2018/2985517
  /government/publications/uk-house-price-index-wales-february-2018/2636299
  /government/publications/uk-house-price-index-wales-january-2018/2607019
  /government/publications/uk-house-price-index-wales-july-2018/2921617
  /government/publications/uk-house-price-index-wales-june-2019/3569381
  /government/publications/uk-house-price-index-wales-may-2018/2761457
  /government/publications/un-general-assembly-ministerial-discussion-on-syria-18-september-2017-joint-statement/2302157
  /government/publications/universal-credit-and-rented-housing--2/3578822
  /government/publications/universal-credit-and-rented-housing--2/3784174
  /government/publications/vat-notes-2018-issue-1/2740872
].freeze

def path_redirects_to_missing_page?(path)
  uri = URI.parse("#{Plek.new.website_root}#{path}")

  Net::HTTP.start(uri.host, use_ssl: true) do |http|
    response = http.request(Net::HTTP::Get.new(uri))

    return false unless response.code == "301"

    redirect_target = URI.parse("#{Plek.new.website_root}#{response['location']}")
    target_response = http.request(Net::HTTP::Get.new(redirect_target))

    target_response.code == "404"
  end
end

desc "Fix some HTML attachments that were incorrectly redirected"
task fix_incorrectly_redirected_html_attachments: :environment do
  PATHS.each do |path|
    raise "invalid path #{path}" unless path_redirects_to_missing_page? path

    html_attachment_id = path.split("/").last.to_i
    html_attachment = HtmlAttachment.find(html_attachment_id)

    PublishingApiWorker
      .new
      .perform(
        html_attachment.class.name,
        html_attachment.id,
        "republish",
        html_attachment.locale || I18n.default_locale.to_s,
      )

    puts "fixed #{path}"
  end
end
