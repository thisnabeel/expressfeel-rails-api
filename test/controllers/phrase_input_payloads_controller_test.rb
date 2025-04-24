require "test_helper"

class PhraseInputPayloadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @phrase_input_payload = phrase_input_payloads(:one)
  end

  test "should get index" do
    get phrase_input_payloads_url, as: :json
    assert_response :success
  end

  test "should create phrase_input_payload" do
    assert_difference("PhraseInputPayload.count") do
      post phrase_input_payloads_url, params: { phrase_input_payload: { factory_dynamic_input_id: @phrase_input_payload.factory_dynamic_input_id, phrase_input_id: @phrase_input_payload.phrase_input_id, phrase_payload_id: @phrase_input_payload.phrase_payload_id } }, as: :json
    end

    assert_response :created
  end

  test "should show phrase_input_payload" do
    get phrase_input_payload_url(@phrase_input_payload), as: :json
    assert_response :success
  end

  test "should update phrase_input_payload" do
    patch phrase_input_payload_url(@phrase_input_payload), params: { phrase_input_payload: { factory_dynamic_input_id: @phrase_input_payload.factory_dynamic_input_id, phrase_input_id: @phrase_input_payload.phrase_input_id, phrase_payload_id: @phrase_input_payload.phrase_payload_id } }, as: :json
    assert_response :success
  end

  test "should destroy phrase_input_payload" do
    assert_difference("PhraseInputPayload.count", -1) do
      delete phrase_input_payload_url(@phrase_input_payload), as: :json
    end

    assert_response :no_content
  end
end
