require "test_helper"

class PhraseInputPermitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @phrase_input_permit = phrase_input_permits(:one)
  end

  test "should get index" do
    get phrase_input_permits_url, as: :json
    assert_response :success
  end

  test "should create phrase_input_permit" do
    assert_difference("PhraseInputPermit.count") do
      post phrase_input_permits_url, params: { phrase_input_permit: { material_tag_option_id: @phrase_input_permit.material_tag_option_id, permit: @phrase_input_permit.permit, phrase_input_id: @phrase_input_permit.phrase_input_id } }, as: :json
    end

    assert_response :created
  end

  test "should show phrase_input_permit" do
    get phrase_input_permit_url(@phrase_input_permit), as: :json
    assert_response :success
  end

  test "should update phrase_input_permit" do
    patch phrase_input_permit_url(@phrase_input_permit), params: { phrase_input_permit: { material_tag_option_id: @phrase_input_permit.material_tag_option_id, permit: @phrase_input_permit.permit, phrase_input_id: @phrase_input_permit.phrase_input_id } }, as: :json
    assert_response :success
  end

  test "should destroy phrase_input_permit" do
    assert_difference("PhraseInputPermit.count", -1) do
      delete phrase_input_permit_url(@phrase_input_permit), as: :json
    end

    assert_response :no_content
  end
end
