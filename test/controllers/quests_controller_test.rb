require "test_helper"

class QuestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @quest = quests(:one)
  end

  test "should get index" do
    get quests_url, as: :json
    assert_response :success
  end

  test "should create quest" do
    assert_difference("Quest.count") do
      post quests_url, params: { quest: { description: @quest.description, difficulty: @quest.difficulty, image_url: @quest.image_url, language_id: @quest.language_id, position: @quest.position, quest_id: @quest.quest_id, title: @quest.title } }, as: :json
    end

    assert_response :created
  end

  test "should show quest" do
    get quest_url(@quest), as: :json
    assert_response :success
  end

  test "should update quest" do
    patch quest_url(@quest), params: { quest: { description: @quest.description, difficulty: @quest.difficulty, image_url: @quest.image_url, language_id: @quest.language_id, position: @quest.position, quest_id: @quest.quest_id, title: @quest.title } }, as: :json
    assert_response :success
  end

  test "should destroy quest" do
    assert_difference("Quest.count", -1) do
      delete quest_url(@quest), as: :json
    end

    assert_response :no_content
  end
end
