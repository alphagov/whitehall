desc "Analyse component usage"
task :analyse_component_usage, %i[document_class number_of_docs type_field_name type_field_value] => :environment do |_, args|
  document_class = args[:document_class]
  number_of_docs = args[:number_of_docs]
  type_field_name = args[:type_field_name]
  type_field_value = args[:type_field_value]

  @patterns = {
    heading: /##+ /,
    underline_heading: /(--+)|(==+)/,
    blockquote: /> /,
    bullet: /^- /,
    list: /1\./,
    code_block: /`/,
    links: /[^x]\[.+\]\(.+\)/,
    email_link: /<.+\..+>/,
    markdown_images: /!\[.+\]\(.+\)/,
    information_callouts: /[^\[]\^.+/,
    warning_callouts: /%.+/,
    example_callout: /\$E /,
    statistic_headline: /{stat-headline}/,
    contact_block: /\$C[ |\n\r]/,
    address: /\$A[ |\n\r]/,
    downloads: /\$D[ |\n\r]/,
    place: /\$P[ |\n\r]/,
    information: /\$I[ |\n\r]/,
    additional_information: /\$AI[ |\n\r]/,
    call_to_action: /\$CTA[ |\n\r]/,
    external_link: /x\[.+\]\(.+\)x/,
    step: /s1./,
    legislative_list: /\* 1./,
    devolved_content: /:((england)|(scotland)|(london)|(wales)|(northern-ireland)|(england-wales)|):/,
    table: /\|.*\|.*\|/,
    barchart: /{barchart}/,
    attachment: /(\[Attachment:)|(!@\d)/,
    attachment_link: /(\[AttachmentLink:)|(\[InlineAttachment:)/,
    image: /(\[Image:)|(!!\d)/,
    embeded_link: /\[embed:link:/,
    embeded_contact: /\[Contact:/,
    button: /{button}/,
    acronym: /\*\[\w+\]:/,
    supersubscript: /<(sup)|(sub)>/,
    video: /youtube.com/,
    footnote: /\[\^\d+\]/,
  }
  @results = @patterns.keys.index_with { |_x| 0 }

  documents = if type_field_name
                document_class.constantize.where("#{type_field_name}": type_field_value).last(number_of_docs)
              else
                document_class.constantize.last(number_of_docs)
              end

  documents.map { |item| count_documents_using_the_components(item.body) }

  @results.each do |key, value|
    Sidekiq.logger.info("#{key.capitalize}: is used (at least once) by #{value} documents")
  end
end

def count_documents_using_the_components(text)
  @patterns.each do |component, pattern|
    @results[component] = @results[component] + 1 if text =~ pattern
  end
end
