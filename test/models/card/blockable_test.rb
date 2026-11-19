require "test_helper"

class Card::BlockableTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "block and unblock" do
    card = cards(:logo)
    blocker = cards(:layout)

    assert_not card.blocked?

    assert_difference -> { card.card_dependencies.count }, 1 do
      card.block(blocker)
    end

    assert card.blocked?
    assert_includes card.blockers, blocker
    assert_includes blocker.blocked_cards, card

    assert_difference -> { card.card_dependencies.count }, -1 do
      card.unblock(blocker)
    end

    assert_not card.reload.blocked?
  end

  test "blocked? is false once the blocker closes" do
    card = cards(:logo)
    blocker = cards(:layout)
    card.block(blocker)

    assert card.blocked?

    blocker.close

    assert_not card.reload.blocked?
  end

  test "unblocked scope excludes cards with an open blocker" do
    card = cards(:logo)
    blocker = cards(:layout)
    card.block(blocker)

    assert_not_includes Card.unblocked, card
    assert_includes Card.unblocked, blocker
    assert_includes Card.unblocked, cards(:text)
  end

  test "unblocked scope includes cards whose blocker is closed" do
    card = cards(:logo)
    blocker = cards(:shipping)
    assert blocker.closed?

    card.block(blocker)

    assert_includes Card.unblocked, card
  end

  test "cannot block itself" do
    card = cards(:logo)
    dependency = card.card_dependencies.build(blocker: card)

    assert_not dependency.valid?
  end

  test "cannot duplicate a dependency" do
    card = cards(:logo)
    blocker = cards(:layout)
    card.block(blocker)

    duplicate = card.card_dependencies.build(blocker: blocker)

    assert_not duplicate.valid?
  end

  test "blocker must belong to the same account" do
    card = cards(:logo)
    blocker = cards(:radio)

    dependency = card.card_dependencies.build(blocker: blocker)

    assert_not dependency.valid?
  end
end
