require "test_helper"

class Cards::ParentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "create as JSON" do
    card = cards(:logo)
    parent = cards(:layout)

    assert_nil card.parent

    post card_parent_path(card), params: { parent_number: parent.number }, as: :json

    assert_response :no_content
    assert_equal parent, card.reload.parent
  end

  test "create as JSON rejects a parent that would create a cycle" do
    card = cards(:logo)
    other = cards(:layout)
    card.update!(parent: other)

    post card_parent_path(other), params: { parent_number: card.number }, as: :json

    assert_response :unprocessable_entity
  end

  test "destroy as JSON" do
    card = cards(:logo)
    parent = cards(:layout)
    card.update!(parent: parent)

    delete card_parent_path(card), as: :json

    assert_response :no_content
    assert_nil card.reload.parent
  end
end
