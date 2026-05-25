require "test_helper"

class TodoTest < ActiveSupport::TestCase
  test "toggle_high_priority! flips high_priority" do
    todo = todos(:one)
    assert_not todo.high_priority?

    todo.toggle_high_priority!
    assert todo.high_priority?

    todo.toggle_high_priority!
    assert_not todo.high_priority?
  end
end
