module Fastlane
  module Actions
    class YkGitCommitAllAction < Action
      def self.run(params)
        Actions.sh "git add -A"
        Actions.sh "git commit -am \"#{params[:message]}\""
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Commit all unsaved changes to git."
      end

      def self.details
        "Commit all unsaved changes to git."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_YK_GIT_COMMIT_ALL", # The name of the environment variable
                                       description: "The git message for the commit", # a short description of this parameter
                                       is_string: true)
        ]
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["wanyakun"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
