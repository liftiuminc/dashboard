class AddAcceptedTacToPublishers < ActiveRecord::Migration
  def self.up
    add_column :publishers, :accepted_tac, :datetime, :null => true
  end

  def self.down
    remove_column :publishers, :accepted_tac
  end
end
