# fastlane
iOS项目打包、组件发布等公用fastfile及自定义action

## Fastfile

iOS通用Fastfile，包括以下功能：

### 基础类

- yk_syncer 

	同步开发者证书，若git_branch不传，默认从master分支获取.
	使用方法：
	lane中调用 `yk_syncer(git_url: xxx, app_identifier: xxxx, git_branch: xxx, username: xxx) `
	或者
	命令行 `fastlane yk_syncer git_url:xxx app_identifier:xxxx git_branch:xxx username:xxx`

- yk_analyze 

	使用infer分析项目中的问题.
	使用方法： 
	lane中调用 `yk_analyze(workspace: xxx, scheme: xxx)`
	或者
	命令行 `fastlane yk_analyze workspace:xxx scheme:xxx`

### 组件类

- yk_component_release_src 

	发布源码组件.
	使用方法：
	lane中调用 `yk_component_release_src(version: xxx, project: xxx)`
	或者
	命令行 `fastlane yk_component_release_src version:xxx project:xxx`

- yk_component_release_static_lib 

	发布static lib组件.
	使用方法：
	lane中调用 `yk_component_release_static_lib(version: xxx, project: xxx)`
	或者
	命令行 `fastlane yk_component_release_static_lib version:xxx project:xxx`

- yk_component_release_fmk 

	发布Framework组件.
	使用方法：
	lane中调用 `yk_component_release_fmk(version: xxx, project: xxx)`
	或者
	命令行 `fastlane yk_component_release_fmk version:xxx project:xxx`

### 应用类

- yk_app_build 

	应用构建参数较多，推荐在lane中使用.
	使用方法：
	```ruby
    yk_app_build(
      app_identifier: 'com.aioser.Demo',
      app_extension_identifier: 'com.aioser.Demo.NotificationServiceExtension',
      scheme: 'Demo',
      configuration: 'debug',
      derived_data_path: 'derivedData',
      output_directory: 'output',
      output_name:'xxx.ipa',
      build_number: build_number,
      xcodeproj: xcodeproj,
      testflight: true,
      use_match: true,
      manual_publish: true,
      pid: 0,
      cer_git_url: xxxx,
      cer_git_branch: 'master',
      ipapkserver_ip: '192.168.199.100',
      ipapkserver_port: 1234
    )
	```

	参数说明：
	app_identifier 应用标示
	app_extension_identifier 应用扩展标示, 例如推送扩展
	scheme target secheme
	configuration 配置，Release后者Debug
	derived_data_path derived数据目录
	output_directory 输出目录
	output_name ipa输出名字
	build_number 构建build号
	xcodeproj xcode project名字
	testflight 是否为发布到TestFlight构建，若为true，configuration会被设置为Release
	use_match 是否使用match，若为true， 会从cer_git_url的cer_git_branch拉去证书，否则使用sigh， 这需要本地安装证书
	manual_publish 构建完成是否为手动发布，若为true，只做构建，不自动发布到ipapkserver和TestFlight
	pid 构建和发布回调使用，一般可不设置
	cer_git_url 构建证书存放git地址，用于use_match时调用yk_syncer
	cer_git_branch 构建证书存放分支，默认为master，用于use_match时调用yk_syncer
	ipapkserver_ip 内测包发布服务器地址，使用ipapkserver作为内测发布系统， 用于调用yk_app_publish
	ipapkserver_port 内测包发布服务器端口，使用ipapkserver作为内测发布系统，用于调用yk_app_publish

- yk_app_publish 

	应用发布到内测ipapkserver或者TestFlight, 参数较多，推荐在lane中使用
	使用方法：
	```ruby
	yk_app_publish(
      pid: 0,
      ip: '192.168.199.100',
      port: 1234,
      testflight: true, 
      changelog: 'publish version 1.0.0',
      package: 'output/xxx.ipa' 
    )
    ```

- yk_testflight_publish

	从TestFlight选择一个build，发布到appstore
	使用方法：
	lane中调用 `yk_testflight_publish(build: xxxxxx)`
	或者
	命令行 `fastlane yk_testflight_publish build:xxxxxx`

