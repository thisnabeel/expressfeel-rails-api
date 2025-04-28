require "test_helper"

class PhraseInputsPermitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @phrase_inputs_permit = phrase_inputs_permits(:one)
  end

  test "should get index" do
    get phrase_inputs_permits_url, as: :json
    assert_response :success
  end

  test "should create phrase_inputs_permit" do
    assert_difference("PhraseInputsPermit.count") do
      post phrase_inputs_permits_url, params: { phrase_inputs_permit: { material_tag_option_id: @phrase_inputs_permit.material_tag_option_id, permit: @phrase_inputs_permit.permit, phrase_input_id: @phrase_inputs_permit.phrase_input_id } }, as: :json
    end

    assert_response :created
  end

  test "should show phrase_inputs_permit" do
    get phrase_inputs_permit_url(@phrase_inputs_permit), as: :json
    assert_response :success
  end

  test "should update phrase_inputs_permit" do
    patch phrase_inputs_permit_url(@phrase_inputs_permit), params: { phrase_inputs_permit: { material_tag_option_id: @phrase_inputs_permit.material_tag_option_id, permit: @phrase_inputs_permit.permit, phrase_input_id: @phrase_inputs_permit.phrase_input_id } }, as: :json
    assert_response :success
  end

  test "should destroy phrase_inputs_permit" do
    assert_difference("PhraseInputsPermit.count", -1) do
      delete phrase_inputs_permit_url(@phrase_inputs_permit), as: :json
    end

    assert_response :no_content
  end
end
