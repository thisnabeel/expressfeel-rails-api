require "test_helper"

class PhraseOrderingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @phrase_ordering = phrase_orderings(:one)
  end

  test "should get index" do
    get phrase_orderings_url, as: :json
    assert_response :success
  end

  test "should create phrase_ordering" do
    assert_difference("PhraseOrdering.count") do
      post phrase_orderings_url, params: { phrase_ordering: { description: @phrase_ordering.description, line: @phrase_ordering.line, phrase_id: @phrase_ordering.phrase_id, position: @phrase_ordering.position } }, as: :json
    end

    assert_response :created
  end

  test "should show phrase_ordering" do
    get phrase_ordering_url(@phrase_ordering), as: :json
    assert_response :success
  end

  test "should update phrase_ordering" do
    patch phrase_ordering_url(@phrase_ordering), params: { phrase_ordering: { description: @phrase_ordering.description, line: @phrase_ordering.line, phrase_id: @phrase_ordering.phrase_id, position: @phrase_ordering.position } }, as: :json
    assert_response :success
  end

  test "should destroy phrase_ordering" do
    assert_difference("PhraseOrdering.count", -1) do
      delete phrase_ordering_url(@phrase_ordering), as: :json
    end

    assert_response :no_content
  end
end
