require "test_helper"

class PhraseInputsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @phrase_input = phrase_inputs(:one)
  end

  test "should get index" do
    get phrase_inputs_url, as: :json
    assert_response :success
  end

  test "should create phrase_input" do
    assert_difference("PhraseInput.count") do
      post phrase_inputs_url, params: { phrase_input: { code: @phrase_input.code, phrase_id: @phrase_input.phrase_id, phrase_inputable_id: @phrase_input.phrase_inputable_id, phrase_inputable_type: @phrase_input.phrase_inputable_type, position: @phrase_input.position } }, as: :json
    end

    assert_response :created
  end

  test "should show phrase_input" do
    get phrase_input_url(@phrase_input), as: :json
    assert_response :success
  end

  test "should update phrase_input" do
    patch phrase_input_url(@phrase_input), params: { phrase_input: { code: @phrase_input.code, phrase_id: @phrase_input.phrase_id, phrase_inputable_id: @phrase_input.phrase_inputable_id, phrase_inputable_type: @phrase_input.phrase_inputable_type, position: @phrase_input.position } }, as: :json
    assert_response :success
  end

  test "should destroy phrase_input" do
    assert_difference("PhraseInput.count", -1) do
      delete phrase_input_url(@phrase_input), as: :json
    end

    assert_response :no_content
  end
end
