require "test_helper"

class PhraseFactoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @phrase_factory = phrase_factories(:one)
  end

  test "should get index" do
    get phrase_factories_url, as: :json
    assert_response :success
  end

  test "should create phrase_factory" do
    assert_difference("PhraseFactory.count") do
      post phrase_factories_url, params: { phrase_factory: { code: @phrase_factory.code, factory_id: @phrase_factory.factory_id, phrase_id: @phrase_factory.phrase_id, position: @phrase_factory.position } }, as: :json
    end

    assert_response :created
  end

  test "should show phrase_factory" do
    get phrase_factory_url(@phrase_factory), as: :json
    assert_response :success
  end

  test "should update phrase_factory" do
    patch phrase_factory_url(@phrase_factory), params: { phrase_factory: { code: @phrase_factory.code, factory_id: @phrase_factory.factory_id, phrase_id: @phrase_factory.phrase_id, position: @phrase_factory.position } }, as: :json
    assert_response :success
  end

  test "should destroy phrase_factory" do
    assert_difference("PhraseFactory.count", -1) do
      delete phrase_factory_url(@phrase_factory), as: :json
    end

    assert_response :no_content
  end
end
