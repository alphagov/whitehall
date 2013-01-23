# encoding=utf-8
require 'whitehall/uploader/parsers'
require 'govspeak'
require 'action_view'
require 'strscan'

class Whitehall::Uploader::Parsers::SummariseBody
  class Govspeaker
    def self.htmlize(text)
      ::Govspeak::Document.new(text).to_html
    end
  end

  class Sanitizer
    def self.sanitize(text)
      entity_decoder.decode(::ActionView::Base.full_sanitizer.sanitize(text))
    end
    def self.entity_decoder
      @entity_decoder ||= HTMLEntities.new
    end
  end

  def initialize(body_text_as_govspeak, govspeaker = Govspeaker, sanitizer = Sanitizer)
    @original_text = body_text_as_govspeak
    @govspeaker = govspeaker
    @sanitizer = sanitizer
  end

  def html_text
    @govspeaker.htmlize(@original_text)
  end

  def detagged_text
    @sanitizer.sanitize(html_text)
  end

  def truncate_to(size)
    text_to_work_with = detagged_text
    up_to_size = text_to_work_with[0..size-1]
    rest = text_to_work_with[size..-1]
    if rest.nil?
      up_to_size
    else
      if up_to_size[-1] =~ /\p{Word}+/
        ss = StringScanner.new("#{rest}")
        up_to_size = "#{up_to_size}#{ss.scan(/\p{Word}+/)}"
      end
      "#{up_to_size}…"
    end
  end

  def self.parse(body, size = 140)
    new(body).truncate_to(size)
  end
end
