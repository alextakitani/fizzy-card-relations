class CardDependency < ApplicationRecord
  belongs_to :account, default: -> { card.account }
  belongs_to :card, touch: true
  belongs_to :blocker, class_name: "Card"

  validates :blocker_id, uniqueness: { scope: :card_id }
  validate :blocker_must_differ_from_card
  validate :blocker_must_belong_to_same_account

  private
    def blocker_must_differ_from_card
      errors.add(:blocker, :invalid, message: "can't block itself") if blocker_id.present? && blocker_id == card_id
    end

    def blocker_must_belong_to_same_account
      return if blocker.nil? || card.nil?

      errors.add(:blocker, :invalid, message: "must belong to the same account") if blocker.account_id != card.account_id
    end
end
