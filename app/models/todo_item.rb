class TodoItem < ApplicationRecord
  belongs_to :user
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  validates :title, presence: true
  validates :due_date, presence: true

  scope :incomplete, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
  scope :for_date, ->(date) { where(due_date: date) }
  scope :due_on_or_before, ->(date) { where(due_date: ..date) }
  scope :completed_on, ->(date) { where(completed_at: date.all_day) }
  scope :ordered, -> { order(:position, :created_at) }

  before_create :set_original_due_date
  before_create :set_position
  before_save :sync_hashtags

  def complete!
    update!(completed: true, completed_at: Time.current)
  end

  def uncomplete!
    update!(completed: false, completed_at: nil)
  end

  def rolled_over?
    original_due_date != due_date
  end

  private

  def set_original_due_date
    self.original_due_date = due_date
  end

  def set_position
    max = user.todo_items.maximum(:position) || 0
    self.position = max + 1
  end

  def sync_hashtags
    hashtag_names = MarkdownHelper.extract_hashtags(title)
    self.tags = hashtag_names.map { |name| Tag.find_or_create_by!(name: name) }
  end
end
