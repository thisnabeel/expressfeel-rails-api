require "test_helper"

class QuestStepLessonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @quest_step_lesson = quest_step_lessons(:one)
  end

  test "should get index" do
    get quest_step_lessons_url, as: :json
    assert_response :success
  end

  test "should create quest_step_lesson" do
    assert_difference("QuestStepLesson.count") do
      post quest_step_lessons_url, params: { quest_step_lesson: { lesson_id: @quest_step_lesson.lesson_id, quest_step_id: @quest_step_lesson.quest_step_id } }, as: :json
    end

    assert_response :created
  end

  test "should show quest_step_lesson" do
    get quest_step_lesson_url(@quest_step_lesson), as: :json
    assert_response :success
  end

  test "should update quest_step_lesson" do
    patch quest_step_lesson_url(@quest_step_lesson), params: { quest_step_lesson: { lesson_id: @quest_step_lesson.lesson_id, quest_step_id: @quest_step_lesson.quest_step_id } }, as: :json
    assert_response :success
  end

  test "should destroy quest_step_lesson" do
    assert_difference("QuestStepLesson.count", -1) do
      delete quest_step_lesson_url(@quest_step_lesson), as: :json
    end

    assert_response :no_content
  end
end
