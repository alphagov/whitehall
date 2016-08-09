class PublishingApiGoneWorker < PublishingApiWorker
  def perform(content_id, *args)
    if args.length == 1
      locale = args[0]
    else
      alternative_path, explanation, locale = args
    end

    Whitehall.publishing_api_v2_client.unpublish(
      content_id,
      alternative_path: alternative_path,
      explanation: explanation,
      type: "gone",
      locale: locale,
    )
  end
end
