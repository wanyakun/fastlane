module Fastlane
  module Actions

    class YkPodInstallAction < Action
      def self.run(params)
        Actions.sh "pod repo update yk && cd Example && pod install"
        UI.message "Successfully pod install ⬆️ ".green
      end

      #####################################################
      # @!group Documentation
      #####################################################
      
      def self.description
        "Update all pods"
      end

      def self.details
        "Update all pods"
      end

      def self.authors
        ["wanyakun"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
