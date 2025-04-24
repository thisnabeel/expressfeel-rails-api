require "test_helper"

class FactoryDynamicOutputsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @factory_dynamic_output = factory_dynamic_outputs(:one)
  end

  test "should get index" do
    get factory_dynamic_outputs_url, as: :json
    assert_response :success
  end

  test "should create factory_dynamic_output" do
    assert_difference("FactoryDynamicOutput.count") do
      post factory_dynamic_outputs_url, params: { factory_dynamic_output: { factory_dynamic_input_id: @factory_dynamic_output.factory_dynamic_input_id, initial_input_key: @factory_dynamic_output.initial_input_key, position: @factory_dynamic_output.position, slug: @factory_dynamic_output.slug } }, as: :json
    end

    assert_response :created
  end

  test "should show factory_dynamic_output" do
    get factory_dynamic_output_url(@factory_dynamic_output), as: :json
    assert_response :success
  end

  test "should update factory_dynamic_output" do
    patch factory_dynamic_output_url(@factory_dynamic_output), params: { factory_dynamic_output: { factory_dynamic_input_id: @factory_dynamic_output.factory_dynamic_input_id, initial_input_key: @factory_dynamic_output.initial_input_key, position: @factory_dynamic_output.position, slug: @factory_dynamic_output.slug } }, as: :json
    assert_response :success
  end

  test "should destroy factory_dynamic_output" do
    assert_difference("FactoryDynamicOutput.count", -1) do
      delete factory_dynamic_output_url(@factory_dynamic_output), as: :json
    end

    assert_response :no_content
  end
end
