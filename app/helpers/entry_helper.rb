module EntryHelper
  TAG_COLORS = {
    "did" => "border-success bg-success/10",
    "thought" => "border-info bg-info/10",
    "idea" => "border-warning bg-warning/10",
    "win" => "border-accent bg-accent/10",
    "emotion" => "border-error bg-error/10"
  }.freeze

  TAG_BADGE_COLORS = {
    "did" => "badge-success",
    "thought" => "badge-info",
    "idea" => "badge-warning",
    "win" => "badge-accent",
    "emotion" => "badge-error"
  }.freeze

  def entry_color_classes(tag)
    TAG_COLORS.fetch(tag.to_s, "border-base-300 bg-base-200/10")
  end

  def entry_badge_class(tag)
    TAG_BADGE_COLORS.fetch(tag.to_s, "badge-ghost")
  end
end
