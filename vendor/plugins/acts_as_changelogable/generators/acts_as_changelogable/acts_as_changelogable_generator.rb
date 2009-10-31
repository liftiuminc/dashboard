class ActsAsChangelogableGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.migration_template 'migration.rb',
                           'db/migrate',
                           :assigns => {
                                        :migration_name => "CreateActsAsChangelog"
                                       },
                           :migration_file_name => "create_acts_as_changelog"
    end
  end
end
