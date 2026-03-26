class Category < ApplicationRecord
  belongs_to :user
  has_many :notes, dependent: :nullify

  validates :name, presence: true, length: { maximum: 50 }
  validates :color, presence: true, format: { with: /\A#[0-9a-fA-F]{6}\z/ }
end
