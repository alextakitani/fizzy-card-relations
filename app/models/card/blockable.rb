module Card::Blockable
  extend ActiveSupport::Concern

  included do
    has_many :card_dependencies, dependent: :destroy
    has_many :blockers, through: :card_dependencies

    has_many :blocking_dependencies, class_name: "CardDependency", foreign_key: :blocker_id, inverse_of: :blocker, dependent: :destroy
    has_many :blocked_cards, through: :blocking_dependencies, source: :card

    scope :unblocked, -> {
      open_blocker_dependencies = CardDependency.joins(:blocker).merge(Card.open)

      where.not(id: open_blocker_dependencies.select(:card_id))
    }
  end

  def blocked?
    blockers.open.any?
  end

  def block(blocker)
    card_dependencies.create(blocker: blocker)
  end

  def unblock(blocker)
    card_dependencies.destroy_by(blocker: blocker)
  end
end
