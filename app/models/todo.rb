class Todo < ApplicationRecord
  def toggle_high_priority!
    update!(high_priority: !high_priority)
  end
end
