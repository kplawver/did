class Entry < ApplicationRecord
  belongs_to :user
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  enum :tag, { did: 0, thought: 1, idea: 2, win: 3, emotion: 4 }

  validates :body, presence: true
  validates :tag, presence: true
  validates :posted_on, presence: true

  scope :for_date, ->(date) { where(posted_on: date) }
  scope :by_tag, ->(tag) { where(tag: tag) }
  scope :chronological, -> { order(:created_at) }

  before_save :render_body_html
  before_save :sync_hashtags

  private

  def render_body_html
    self.body_html = MarkdownHelper.render(body)
  end

  def sync_hashtags
    hashtag_names = MarkdownHelper.extract_hashtags(body)
    self.tags = hashtag_names.map { |name| Tag.find_or_create_by!(name: name) }
  end
end
