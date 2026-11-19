require "test_helper"

class Card::HierarchicalTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "parent and children" do
    card = cards(:logo)
    parent = cards(:layout)

    assert_nil card.parent

    card.update!(parent: parent)

    assert_equal parent, card.reload.parent
    assert_includes parent.children, card
  end

  test "roots scope excludes cards with a parent" do
    card = cards(:logo)
    parent = cards(:layout)
    card.update!(parent: parent)

    assert_not_includes Card.roots, card
    assert_includes Card.roots, parent
    assert_includes Card.roots, cards(:text)
  end

  test "cannot be its own parent" do
    card = cards(:logo)
    card.parent = card

    assert_not card.valid?
  end

  test "cannot create a direct cycle" do
    card = cards(:logo)
    other = cards(:layout)
    card.update!(parent: other)

    other.parent = card

    assert_not other.valid?
  end

  test "cannot create a longer cycle" do
    a = cards(:logo)
    b = cards(:layout)
    c = cards(:text)

    b.update!(parent: a)
    c.update!(parent: b)

    a.parent = c

    assert_not a.valid?
  end

  test "parent must belong to the same account" do
    card = cards(:logo)
    other_account_card = cards(:radio)

    card.parent = other_account_card

    assert_not card.valid?
  end

  test "deleting the parent nullifies children instead of destroying them" do
    card = cards(:logo)
    parent = cards(:layout)
    card.update!(parent: parent)

    parent.destroy

    assert_nil card.reload.parent_id
  end

  test "gaining a child touches the parent" do
    card = cards(:logo)
    parent = cards(:layout)

    assert_changes -> { parent.reload.updated_at } do
      card.update!(parent: parent)
    end
  end

  # Without this the parent keeps the timestamp it had while the child was still
  # attached, so its cached JSON serves a children_count that no longer matches.
  test "losing a child touches the parent it left" do
    card = cards(:logo)
    parent = cards(:layout)
    card.update!(parent: parent)

    assert_changes -> { parent.reload.updated_at } do
      card.update!(parent: nil)
    end
  end
end
