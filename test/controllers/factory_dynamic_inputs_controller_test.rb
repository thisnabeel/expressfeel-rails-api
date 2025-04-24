require "test_helper"

class FactoryDynamicInputsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @factory_dynamic_input = factory_dynamic_inputs(:one)
  end

  test "should get index" do
    get factory_dynamic_inputs_url, as: :json
    assert_response :success
  end

  test "should create factory_dynamic_input" do
    assert_difference("FactoryDynamicInput.count") do
      post factory_dynamic_inputs_url, params: { factory_dynamic_input: { factory_dynamic_id: @factory_dynamic_input.factory_dynamic_id, factory_id: @factory_dynamic_input.factory_id, position: @factory_dynamic_input.position, selected_rule: @factory_dynamic_input.selected_rule, slug: @factory_dynamic_input.slug } }, as: :json
    end

    assert_response :created
  end

  test "should show factory_dynamic_input" do
    get factory_dynamic_input_url(@factory_dynamic_input), as: :json
    assert_response :success
  end

  test "should update factory_dynamic_input" do
    patch factory_dynamic_input_url(@factory_dynamic_input), params: { factory_dynamic_input: { factory_dynamic_id: @factory_dynamic_input.factory_dynamic_id, factory_id: @factory_dynamic_input.factory_id, position: @factory_dynamic_input.position, selected_rule: @factory_dynamic_input.selected_rule, slug: @factory_dynamic_input.slug } }, as: :json
    assert_response :success
  end

  test "should destroy factory_dynamic_input" do
    assert_difference("FactoryDynamicInput.count", -1) do
      delete factory_dynamic_input_url(@factory_dynamic_input), as: :json
    end

    assert_response :no_content
  end
end
