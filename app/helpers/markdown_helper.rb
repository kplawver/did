module MarkdownHelper
  HASHTAG_REGEX = /(?<=\s|^)#([a-zA-Z]\w*)\b/

  ENTRY_TAG_NAMES = Entry::TAGS.freeze rescue %w[did thought idea win emotion].freeze

  def self.render(text)
    renderer = Redcarpet::Render::HTML.new(
      hard_wrap: true,
      link_attributes: { target: "_blank", rel: "noopener noreferrer" }
    )
    markdown = Redcarpet::Markdown.new(renderer,
      autolink: true,
      fenced_code_blocks: true,
      strikethrough: true,
      no_intra_emphasis: true
    )
    markdown.render(text).html_safe
  end

  def self.extract_hashtags(text)
    text.scan(HASHTAG_REGEX).flatten
      .map(&:downcase)
      .uniq
      .reject { |t| entry_tag_names.include?(t) }
  end

  def self.entry_tag_names
    %w[did thought idea win emotion]
  end
end
