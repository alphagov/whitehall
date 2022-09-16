class GovspeakContentWorker < WorkerBase
  def perform(id)
    return unless (govspeak_content = GovspeakContent.find_by(id:))

    govspeak_content.render_govspeak!
  end
end
