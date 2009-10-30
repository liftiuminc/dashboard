class FixRevenueDecimals < ActiveRecord::Migration
  def self.up
    change_column( :revenues, :revenue, :decimal, :scale => 6, :precision => 13 )
    change_column( :revenues, :ecpm,    :decimal, :scale => 6, :precision => 13 ) 
  end

  def self.down
  end
end
