module Fastlane
  module Actions
    class YkPodRepoUpdateAction < Action
      def self.run(params)
        Actions.sh "pod repo update yk".to_s
        UI.message "Successfully pod repo update 💾."
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Update the local clone of the spec-repo yk."
      end

      def self.details
        "Update the local clone of the spec-repo yk."
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
