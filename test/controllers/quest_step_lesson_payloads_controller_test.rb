require "test_helper"

class QuestStepLessonPayloadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @quest_step_lesson_payload = quest_step_lesson_payloads(:one)
  end

  test "should get index" do
    get quest_step_lesson_payloads_url, as: :json
    assert_response :success
  end

  test "should create quest_step_lesson_payload" do
    assert_difference("QuestStepLessonPayload.count") do
      post quest_step_lesson_payloads_url, params: { quest_step_lesson_payload: { materialable_id: @quest_step_lesson_payload.materialable_id, materialable_type: @quest_step_lesson_payload.materialable_type, quest_step_lesson_id: @quest_step_lesson_payload.quest_step_lesson_id } }, as: :json
    end

    assert_response :created
  end

  test "should show quest_step_lesson_payload" do
    get quest_step_lesson_payload_url(@quest_step_lesson_payload), as: :json
    assert_response :success
  end

  test "should update quest_step_lesson_payload" do
    patch quest_step_lesson_payload_url(@quest_step_lesson_payload), params: { quest_step_lesson_payload: { materialable_id: @quest_step_lesson_payload.materialable_id, materialable_type: @quest_step_lesson_payload.materialable_type, quest_step_lesson_id: @quest_step_lesson_payload.quest_step_lesson_id } }, as: :json
    assert_response :success
  end

  test "should destroy quest_step_lesson_payload" do
    assert_difference("QuestStepLessonPayload.count", -1) do
      delete quest_step_lesson_payload_url(@quest_step_lesson_payload), as: :json
    end

    assert_response :no_content
  end
end
