class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable, :trackable

  has_many :passkey_credentials, dependent: :destroy
  has_many :todo_items, dependent: :destroy
  has_many :entries, dependent: :destroy

  before_create { self.webauthn_id ||= SecureRandom.uuid }

  validates :username, presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" },
            length: { minimum: 3, maximum: 30 }
end
