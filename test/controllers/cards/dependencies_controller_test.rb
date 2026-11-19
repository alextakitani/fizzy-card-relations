require "test_helper"

class Cards::DependenciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "create as JSON" do
    card = cards(:logo)
    blocker = cards(:layout)

    assert_not card.blocked?

    post card_dependencies_path(card), params: { blocker_number: blocker.number }, as: :json

    assert_response :no_content
    assert card.reload.blocked?
    assert_includes card.blockers, blocker
  end

  test "create as JSON is idempotent-safe against duplicates" do
    card = cards(:logo)
    blocker = cards(:layout)
    card.block(blocker)

    post card_dependencies_path(card), params: { blocker_number: blocker.number }, as: :json

    assert_response :unprocessable_entity
  end

  test "destroy as JSON" do
    card = cards(:logo)
    blocker = cards(:layout)
    card.block(blocker)

    delete card_dependency_path(card, blocker.id), as: :json

    assert_response :no_content
    assert_not card.reload.blocked?
  end
end
