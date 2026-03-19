class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_validation :normalize_name

  private

  def normalize_name
    self.name = name&.downcase&.strip
  end
end
