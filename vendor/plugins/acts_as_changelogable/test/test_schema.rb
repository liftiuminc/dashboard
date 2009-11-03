ActiveRecord::Schema.define(:version => 0) do
  create_table :test_models, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :test_no_changelog_models, :force => true do |t|
    t.string :name
    t.timestamps
  end
end
