require "uri"

module Admin::BasePathHelper
  MAPPINGS = [
    { "CallForEvidence" => "/government/calls-for-evidence" },
    { "CaseStudy" => "/government/case-studies" },
    { "Consultation" => "/government/consultations" },
    { "DetailedGuide" => "/guidance" },
    { "DocumentCollection" => "/government/collections" },
    { "FatalityNotice" => "/government/fatalities" },
    { "OperationalField" => "/government/fields-of-operation" },
    { "Publication" => "/government/publications" },
    { "Publication" => "/government/statistics" },
    { "Speech" => "/government/speeches" },
    { "StatisticalDataSet" => "/government/statistical-data-sets" },
    { "StatisticsAnnouncement" => "/government/statistics/announcements" },
  ].freeze

  HTML_ATTACHMENT_PATH_REGEX = %r{
    \A/government/
    (?!statistics/announcements/)  # exclude /government/statistics/announcements/...
    [^/]+                          # section (e.g. calls-for-evidence, publications, case-studies, etc.)
    /[^/]+                         # document slug
    /[^/]+                         # attachment slug
    \z
  }x

  def url_to_document_type(url)
    full_path = extract_path(url)

    return HtmlAttachment if full_path.match?(HTML_ATTACHMENT_PATH_REGEX)

    path_parts = full_path.split("/")
    path_parts.pop
    prefix = path_parts.join("/")

    matches = MAPPINGS.select do |mapping|
      prefix == mapping.values.first
    end

    raise "No document type found for #{url}" if matches.count.zero?

    return Object.const_get(matches.first.keys.first) if matches.count == 1

    common_superclass(matches.map(&:keys).flatten.compact.map { |klass| Object.const_get(klass) })
  end

  def url_to_document_slug(url)
    full_path = extract_path(url)
    document_type = url_to_document_type(url)
    path_parts = full_path.split("/")

    if document_type == HtmlAttachment
      path_parts[-2]
    else
      path_parts.last
    end
  end

private

  def extract_path(input)
    uri = URI.parse(input)
    uri.path.empty? ? "/" : uri.path
  rescue URI::InvalidURIError
    input.start_with?("/") ? input : "/#{input}"
  end

  def common_superclass(klasses)
    klasses.map(&:ancestors)
          .inject(:&)
          .select { |k| k.is_a?(Class) }
          .reject { |k| k == BasicObject }
          .first
  end
end
