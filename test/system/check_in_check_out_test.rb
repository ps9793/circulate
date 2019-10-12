require "application_system_test_case"

class CheckInCheckOutTest < ApplicationSystemTestCase
  def setup
    sign_in_as_admin
  end

  test "pending member can't checkout items" do
    @member = create(:member)

    visit admin_member_url(@member)

    assert_content "Member not active"
    refute_selector ".member-checkout-items"
  end

  test "checks out items to member" do
    @item = create(:item)
    @member = create(:active_member_with_membership)

    visit admin_member_url(@member)

    fill_in :loan_item_number, with: @item.number
    click_on "Checkout"
    within ".member-active-loans" do
      assert_text @item.name
    end
  end

  test "returns loaned item" do
    @item = create(:item)
    @member = create(:active_member_with_membership)
    create(:loan, item: @item, member: @member)

    visit admin_member_url(@member)

    within ".member-active-loans" do
      assert_text @item.name
      click_on "Return"
    end

    refute_selector ".member-active-loans"

    within ".member-recent-loans" do
      assert_text @item.name
    end
  end

  test "returns loaned overdue item" do
    @item = create(:item)
    @member = create(:active_member_with_membership)
    create(:loan, item: @item, member: @member, due_at: 2.weeks.ago)

    visit admin_member_url(@member)

    within ".member-active-loans" do
      assert_text @item.name
      click_on "Return"
    end

    refute_selector ".member-active-loans"

    within ".member-recent-loans" do
      assert_text @item.name
    end

    assert_content "Balance: $-15.00"
  end
end