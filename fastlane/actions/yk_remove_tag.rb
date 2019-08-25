module Fastlane
  module Actions
    class YkRemoveTagAction < Action
      def self.run(params)
        tag = params[:tag]
        if tag_exists(tag)
          Actions.sh "git tag -d #{tag}"
          Actions.sh "git push origin :refs/tags/#{tag}"
          UI.success("Git tag `#{tag}` removed! 💪")
        else
          UI.user_error!("Git tag #{tag} not exist, please ensure the tag in local and remote")
        end
      end

      def self.tag_exists(tag)
        result = Actions.sh("git rev-parse -q --verify refs/tags/#{tag.shellescape} || true", log: FastlaneCore::Globals.verbose?).chomp
        !result.empty?
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "remvoe the exist tag in local and remote"
      end

      def self.details
        "remvoe the exist tag in local and remote"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :tag,
                                       env_name: "FL_YK_REMOVE_TAG_TAG", # The name of the environment variable
                                       description: "please input tag to remove", # a short description of this parameter
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("remove tag need the tag name") unless (value and not value.empty?)
          end)
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
