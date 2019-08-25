module Fastlane
  module Actions
    class YkPublishIpapkserverAction < Action
      def self.run(params)
        ip = params[:ip]
        port = params[:port]
        pid = params[:pid]
        package = params[:package]
        changelog = params[:changelog]
        command = "curl 'https://#{ip}:#{port}/upload' -F \"pid=#{pid}\" -F \"package=@#{package}\" -F \"changelog=#{changelog}\" --insecure"
        result = Actions.sh command

        UI.message "publish result: #{result}"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "publish test version to ipapk server"
      end

      def self.details
        "publish test version to ipapk server"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ip,
                                       env_name: "FL_YK_PUBLISH_TEST_IP", # The name of the environment variable
                                       description: "please input ipapk server ip address", # a short description of this parameter
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :port,
                                       env_name: "FL_YK_PUBLISH_TEST_PORT", # The name of the environment variable
                                       description: "please input ipapk server port", # a short description of this parameter
                                       is_string: false,
                                       default_value: 1234),
          FastlaneCore::ConfigItem.new(key: :pid,
                                       env_name: "FL_YK_PUBLISH_TEST_PID", # The name of the environment variable
                                       description: "please input ipapk server pid", # a short description of this parameter
                                       is_string: false,
                                       default_value: 0),
          FastlaneCore::ConfigItem.new(key: :package,
                                       env_name: "FL_YK_PUBLISH_TEST_PACKAGE",
                                       description: "ipa or apk file path",
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass the path to the package, not the apk or ipa ifle") if value.end_with? ".ipa" and value.end_with? ".apk"
                                         UI.user_error!("Could not find ipa or apk file") if !File.exist?(value) and !Helper.is_test?
          end),
          FastlaneCore::ConfigItem.new(key: :changelog,
                                       env_name: "FL_YK_PUBLISH_TEST_CHANGELOG",
                                       description: "package changelog of this version",
                                       is_string: true,
                                       default_value: "no changelog")
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
