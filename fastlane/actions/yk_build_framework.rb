module Fastlane
  module Actions
    class YkBuildFrameworkAction < Action
      def self.run(params)
        build_target = params[:project]

        current_path = Dir.pwd
        # 删除当前目录旧的framework和dsym文件
        framework = "#{current_path}/fmk/#{build_target}.framework"
        if File.exist?(framework)
          FileUtils.rm_rf(framework)
        end
        dsym = "#{current_path}/fmk/#{build_target}.framework.dSYM"
        if File.exist?(dsym)
          FileUtils.rm_rf(dsym)
        end

        build_path = "#{current_path}/build"
        build_project = "#{current_path}/Example/Pods/Pods.xcodeproj"

        # 编译configuration，默认为Release
        build_config = "Release"

        # 使用archive构建真机framework
        archive_command = "xcodebuild clean archive -project #{build_project} -scheme #{build_target} -configuration #{build_config} -sdk iphoneos OBJROOT=#{build_path} SYMROOT=#{build_path} ONLY_ACTIVE_ARCH=NO | xcpretty"
        Actions.sh(archive_command)

        # 将真机framework复制到项目根目录
        iphone_framework="#{build_path}/UninstalledProducts/iphoneos/#{build_target}.framework"
        target_framework="#{current_path}/fmk/#{build_target}.framework"

        copy_command = "cp -R #{iphone_framework} #{current_path}/fmk/"
        Actions.sh(copy_command)

        # copy真机符号表文件
        dsym_path = "#{build_path}/#{build_config}-iphoneos/#{build_target}/#{build_target}.framework.dSYM"
        if File.directory?(dsym_path)
          copy_dsym_command = "cp -R #{dsym_path} #{current_path}/fmk/"
          Actions.sh(copy_dsym_command)
        end

        # 使用build构建模拟器framework
        build_command = "xcodebuild clean build -project #{build_project} -scheme #{build_target} -configuration #{build_config} -sdk iphonesimulator OBJROOT=#{build_path} SYMROOT=#{build_path} ONLY_ACTIVE_ARCH=NO | xcpretty"
        Actions.sh(build_command)

        simulator_framework="#{build_path}/#{build_config}-iphonesimulator/#{build_target}/#{build_target}.framework"

        # 将模拟器的swift modules（如果存在）复制到fmk的framework目录
        simulator_swift_module = "#{simulator_framework}/Modules/#{build_target}.swiftmodule/."
        if File.exist?(simulator_swift_module)
          copy_swift_module_command = "cp -R #{simulator_swift_module} #{target_framework}/Modules/#{build_target}.swiftmodule"
          Actions.sh(copy_swift_module_command)


          #merge swift pod header file
          rename_iphoneos_header_file_command = "mv #{target_framework}/Headers/#{build_target}-Swift.h #{target_framework}/Headers/#{build_target}-Swift-iphoneos.h"
          Action.sh(rename_iphoneos_header_file_command)
          rename_simulator_header_file_command = "cp #{simulator_framework}/Headers/#{build_target}-Swift.h #{target_framework}/Headers/#{build_target}-Swift-iphonesimulator.h"
          Action.sh(rename_simulator_header_file_command)

          merged_header_file_name = "#{target_framework}/Headers/#{build_target}-Swift.h"
          Action.sh("echo '#if __x86_64__ || __i386__ ' > #{merged_header_file_name}")
          Action.sh("echo '#include \"#{build_target}-Swift-iphonesimulator.h\"' >> #{merged_header_file_name}")
          Action.sh("echo '#else' >> #{merged_header_file_name}")
          Action.sh("echo '#include \"#{build_target}-Swift-iphoneos.h\"' >> #{merged_header_file_name}")
          Action.sh("echo '#endif' >> #{merged_header_file_name}")

        end

        # 合并真机和模拟器二进制文件
        lipo_command = "lipo -create -output #{target_framework}/#{build_target} #{simulator_framework}/#{build_target} #{target_framework}/#{build_target}"
        Actions.sh(lipo_command)

        # 清理build文件
        Actions.sh "rm -rf #{build_path}"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Build dynamic framework with full bitcode which support iphoneos and simulator"
      end

      def self.details
        "Build dynamic framework with full bitcode which support iphoneos and simulator"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: "FL_YK_BUILD_FRAMEWORK_PROJECT",
                                       description: "The project of the framework. It should be the same with scheme and name in the cocoapods podspec",
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
