require "test_helper"

class FactoryMaterialDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @factory_material_detail = factory_material_details(:one)
  end

  test "should get index" do
    get factory_material_details_url, as: :json
    assert_response :success
  end

  test "should create factory_material_detail" do
    assert_difference("FactoryMaterialDetail.count") do
      post factory_material_details_url, params: { factory_material_detail: { active: @factory_material_detail.active, category: @factory_material_detail.category, factory_material_id: @factory_material_detail.factory_material_id, slug: @factory_material_detail.slug } }, as: :json
    end

    assert_response :created
  end

  test "should show factory_material_detail" do
    get factory_material_detail_url(@factory_material_detail), as: :json
    assert_response :success
  end

  test "should update factory_material_detail" do
    patch factory_material_detail_url(@factory_material_detail), params: { factory_material_detail: { active: @factory_material_detail.active, category: @factory_material_detail.category, factory_material_id: @factory_material_detail.factory_material_id, slug: @factory_material_detail.slug } }, as: :json
    assert_response :success
  end

  test "should destroy factory_material_detail" do
    assert_difference("FactoryMaterialDetail.count", -1) do
      delete factory_material_detail_url(@factory_material_detail), as: :json
    end

    assert_response :no_content
  end
end
