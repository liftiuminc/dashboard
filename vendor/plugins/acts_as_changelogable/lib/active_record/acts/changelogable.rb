module ActiveRecord
  module Acts
    module Changelogable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_changelogable
          class_eval <<-EOV
            include ActiveRecord::Acts::Changelogable::InstanceMethods

            after_create  :create_changelog_entry
            after_update  :update_changelog_entry
            after_destroy :destroy_changelog_entry
          EOV
        end
      end

      module InstanceMethods
        private

        def create_changelog_entry
          changelog_entry("create")
        end

        def update_changelog_entry
          changelog_entry("update")
        end

        def destroy_changelog_entry
          changelog_entry("destroy")
        end

        def changelog_entry(operation)
          Changelog.create(:record_id => self.id, :record_type => self.class.to_s, :user_id => get_user_id, :operation => operation,
                           :diff => self.changes.to_json, :description => "#{self.class} #{operation}d at #{operated_at}")
        end

        def operated_at
          if respond_to?(:updated_at)
            self.updated_at.strftime('%Y-%m-%d %H:%M')
          elsif respond_to?(:updated_at)
            self.created_at.strftime('%Y-%m-%d %H:%M')
          else
            Time.now.strftime('%Y-%m-%d %H:%M')
          end
        end

        def get_user_id
          respond_to?(:current_user) ? current_user.id : nil
        end
      end
    end
  end
end
