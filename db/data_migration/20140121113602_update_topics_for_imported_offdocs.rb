require 'pathname'
require 'csv'

def load_topic(topic_name)
  if topic = Topic.find_by_name(topic_name)
    topic
  else
    puts "Missing topic '#{topic_name}'"
    nil
  end
end

def load_document(old_url)
  if document_source = DocumentSource.find_by_url(old_url)
    document_source.document
  else
    puts "Missing document from URL '#{old_url}'"
    nil
  end
end

def associate_document_with_topic(document, topic)
  edition = document.latest_edition

  if edition.nil?
    puts "No edition for #{document.document_type} '#{document.slug}'"
    return
  end

  if ClassificationMembership.where(classification_id: topic.id, edition_id: edition.id).exists?
    puts "Association between #{document.document_type} '#{document.slug}' and topic '#{topic.slug}' already exists"
  else
    puts "Associating #{document.document_type} '#{document.slug}' with topic '#{topic.slug}'"
    ClassificationMembership.create!(classification: topic, edition: edition)

    editorial_remark = "Imported document associated with topic #{topic.slug}"
    edition.editorial_remarks.create!(author: User.find_by_name!('GDS Inside Government Team'), body: editorial_remark)
  end
end

raise "Missing topics CSV 'db/data_migration/20140121113602_topics-ready-for-load.csv'" unless File.exist?('db/data_migration/20140121113602_topics-ready-for-load.csv')

CSV.foreach('db/data_migration/20140121113602_topics-ready-for-load.csv') do |(old_url, _, topic_name)|
  next if old_url == 'Link'

  next unless topic = load_topic(topic_name.strip)
  next unless document = load_document(old_url.strip)

  associate_document_with_topic(document, topic)
end
