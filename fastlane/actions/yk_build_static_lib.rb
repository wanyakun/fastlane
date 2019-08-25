module Fastlane
  module Actions
    class YkBuildStaticLibAction < Action
      def self.run(params)
        build_target = params[:project]
        current_path = Dir.pwd
        # 删除静态lib.a文件
        lib = "#{current_path}/lib/lib#{build_target}.a"
        if File.exist?(lib)
          FileUtils.rm_rf(lib)
        end
        # 删除头文件
        header_path = "#{current_path}/lib/#{build_target}/"
        if File.exist?(header_path)
          FileUtils.rm_rf(header_path)
        end

        build_path = "#{current_path}/build"
        build_project = "#{current_path}/Example/Pods/Pods.xcodeproj"

        # 编译configuration，默认为Release
        build_config = "Release"

        # 使用archive构建真机lib
        archive_command = "xcodebuild clean archive -project #{build_project} -scheme #{build_target} -configuration #{build_config} -sdk iphoneos OBJROOT=#{build_path} SYMROOT=#{build_path} ONLY_ACTIVE_ARCH=NO | xcpretty"
        Actions.sh(archive_command)

        # 将真机lib和header复制到项目根目录的lib目录下
        iphone_lib = "#{build_path}/UninstalledProducts/iphoneos/"

        copy_command = "cp -R #{iphone_lib} #{current_path}/lib/"
        Actions.sh(copy_command)

        iphone_header = "#{current_path}/Example/Pods/Headers/Public/#{build_target}/"
        copy_header_command = "cp -r #{iphone_header} #{header_path}"
        Actions.sh(copy_header_command)

        # 将真机的swift modules（如果存在）复制到lib的目录
        iphone_swift_module = "#{build_path}/Release-iphoneos/#{build_target}/#{build_target}.swiftmodule/."
        if File.exist?(iphone_swift_module)
          copy_iphone_swift_module_command = "cp -R #{iphone_swift_module} #{current_path}/lib/#{build_target}/#{build_target}.swiftmodule"
          Actions.sh(copy_iphone_swift_module_command)
        end

        # 将swift Header copy到lib中
        swift_header_path = "#{build_path}/Release-iphoneos/#{build_target}/Swift Compatibility Header/"
        swift_header = "#{build_path}/Release-iphoneos/#{build_target}/Swift\\ Compatibility\\ Header/"
        if File.directory?(swift_header_path)
          copy_swift_header_command = "cp -r #{swift_header} #{header_path}"
          Actions.sh(copy_swift_header_command)
        end

        # 使用build构建模拟器lib, 只build 64位模拟器的
        build_command = "xcodebuild clean build -project #{build_project} -scheme #{build_target} -configuration #{build_config} -sdk iphonesimulator OBJROOT=#{build_path} SYMROOT=#{build_path} ONLY_ACTIVE_ARCH=NO | xcpretty"
        Actions.sh(build_command)

        # 将模拟器的swift module 复制到lib中
        simulator_swift_module = "#{build_path}/Release-iphonesimulator/#{build_target}/#{build_target}.swiftmodule/."
        if File.exist?(simulator_swift_module)
          copy_simulator_swift_module_command = "cp -R #{simulator_swift_module} #{current_path}/lib/#{build_target}/#{build_target}.swiftmodule"
          Actions.sh(copy_simulator_swift_module_command)

          #merge swift pod header file
          rename_iphoneos_header_file_command = "mv #{header_path}/#{build_target}-Swift.h #{header_path}#{build_target}-Swift-iphoneos.h"
          Action.sh(rename_iphoneos_header_file_command)

          simulator_header_file_src = "'#{build_path}/Release-iphonesimulator/#{build_target}/Swift Compatibility Header/#{build_target}-Swift.h'"
          simulator_header_file_dst = "#{header_path}#{build_target}-Swift-iphonesimulator.h"
          rename_simulator_header_file_command = "cp #{simulator_header_file_src} #{simulator_header_file_dst}"
          Action.sh(rename_simulator_header_file_command)

          merged_header_file_name = "#{header_path}#{build_target}-Swift.h"
          Action.sh("echo '#if __x86_64__ || __i386__ ' > #{merged_header_file_name}")
          Action.sh("echo '#include \"#{build_target}-Swift-iphonesimulator.h\"' >> #{merged_header_file_name}")
          Action.sh("echo '#else' >> #{merged_header_file_name}")
          Action.sh("echo '#include \"#{build_target}-Swift-iphoneos.h\"' >> #{merged_header_file_name}")
          Action.sh("echo '#endif' >> #{merged_header_file_name}")

        end

        # 合并真机和模拟器二进制文件
        simulator_lib="#{build_path}/#{build_config}-iphonesimulator/#{build_target}/lib#{build_target}.a"
        target_lib="#{current_path}/lib/lib#{build_target}.a"
        lipo_command = "lipo -create -output #{target_lib} #{simulator_lib} #{target_lib}"
        Actions.sh(lipo_command)

        # 清理build文件
        Actions.sh "rm -rf #{build_path}"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Build static lib with full bitcode which support iphoneos and simulator"
      end

      def self.details
        "Build static lib with full bitcode which support iphoneos and simulator"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: "FL_YK_BUILD_STATIC_LIB_PROJECT",
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
