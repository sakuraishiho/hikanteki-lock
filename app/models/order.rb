class Order < ApplicationRecord
  belongs_to :user
  has_many :ordered_lists
  has_many :items, through: :ordered_lists
  accepts_nested_attributes_for :ordered_lists

  def update_total_quantity
    ActiveRecord::Base.transaction do
      # 悲観的ロックをかけて他のプロセスが同じデータを更新しないようにする
      item = ordered_lists.first.item.lock!
      new_total = item.total_quantity + ordered_lists.sum(:quantity)
      item.update!(total_quantity: new_total)
    end
  end
end
