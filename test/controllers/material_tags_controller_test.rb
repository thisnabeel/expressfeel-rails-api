require "test_helper"

class MaterialTagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @material_tag = material_tags(:one)
  end

  test "should get index" do
    get material_tags_url, as: :json
    assert_response :success
  end

  test "should create material_tag" do
    assert_difference("MaterialTag.count") do
      post material_tags_url, params: { material_tag: { factory_material_id: @material_tag.factory_material_id, material_tag_option_id: @material_tag.material_tag_option_id } }, as: :json
    end

    assert_response :created
  end

  test "should show material_tag" do
    get material_tag_url(@material_tag), as: :json
    assert_response :success
  end

  test "should update material_tag" do
    patch material_tag_url(@material_tag), params: { material_tag: { factory_material_id: @material_tag.factory_material_id, material_tag_option_id: @material_tag.material_tag_option_id } }, as: :json
    assert_response :success
  end

  test "should destroy material_tag" do
    assert_difference("MaterialTag.count", -1) do
      delete material_tag_url(@material_tag), as: :json
    end

    assert_response :no_content
  end
end
