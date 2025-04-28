require "test_helper"

class MaterialCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @material_category = material_categories(:one)
  end

  test "should get index" do
    get material_categories_url, as: :json
    assert_response :success
  end

  test "should create material_category" do
    assert_difference("MaterialCategory.count") do
      post material_categories_url, params: { material_category: { factory_material_id: @material_category.factory_material_id, material_category_option_id: @material_category.material_category_option_id } }, as: :json
    end

    assert_response :created
  end

  test "should show material_category" do
    get material_category_url(@material_category), as: :json
    assert_response :success
  end

  test "should update material_category" do
    patch material_category_url(@material_category), params: { material_category: { factory_material_id: @material_category.factory_material_id, material_category_option_id: @material_category.material_category_option_id } }, as: :json
    assert_response :success
  end

  test "should destroy material_category" do
    assert_difference("MaterialCategory.count", -1) do
      delete material_category_url(@material_category), as: :json
    end

    assert_response :no_content
  end
end
