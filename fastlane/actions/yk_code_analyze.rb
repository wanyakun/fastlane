module Fastlane
  module Actions
    class YkCodeAnalyzeAction < Action
      def self.run(params)
        workspace = params[:workspace]
        scheme = params[:scheme]
        project = params[:project]
        current_path = Dir.pwd
        build_path = "#{current_path}/build/"
        infer_path = "#{current_path}/infer-out/"
        if File.exist?(build_path)
          FileUtils.rm_rf(build_path)
        end
        if File.exist?(infer_path)
          FileUtils.rm_rf(infer_path)
        end

        if project
          infer_command = "infer --skip-analysis-in-path Example/Pods -- xcodebuild clean build -workspace Example/#{project}.xcworkspace -scheme #{project} -configuration Debug | xcpretty"
        else
          infer_command = "infer --skip-analysis-in-path Example/Pods -- xcodebuild clean build -workspace #{workspace} -scheme #{scheme} -configuration Debug | xcpretty"
        end
        Actions.sh(infer_command)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Analyze the code of the component or App."
      end

      def self.details
        "Analyze the code of the component or App."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :workspace,
                                       env_name: "FL_YK_BUILD_STATIC_LIB_WORKSPACE",
                                       description: "The workspace of the component or App. If component it should be the same with scheme and name in the cocoapods podspec",
                                       is_string: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass the path to the workspace") unless value.end_with?(".xcworkspace")
                                         UI.user_error!("Could not find Xcode workspace") unless File.exist?(value)
          end),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: "FL_YK_BUILD_STATIC_LIB_SCHEME",
                                       description: "The scheme of the component or App. If component it should be the same with scheme and name in the cocoapods podspec",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: "FL_YK_BUILD_STATIC_LIB_PROJECT",
                                       description: "The project of the component. It should be the same with scheme and name in the cocoapods podspec",
                                       is_string: true,
                                       optional: true)
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
