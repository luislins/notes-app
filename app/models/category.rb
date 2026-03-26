class Category < ApplicationRecord
  belongs_to :user
  has_many :notes, dependent: :nullify

  validates :name, presence: true
  validates :color, presence: true
end
