class Note < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  validates :title, presence: true, length: { maximum: 255 }
  validates :content, length: { maximum: 10_000 }, allow_blank: true
  validate :category_belongs_to_user, if: -> { category_id.present? && category_id_changed? }

  private

  def category_belongs_to_user
    return if category&.user_id == user_id

    errors.add(:category, :invalid)
  end
end
