platform :ios, '14.0'
use_frameworks!

# Use CocoaPods only if SPM is not available
target 'RoutineApp' do
  pod 'Firebase/AnalyticsWithoutAdIdSupport'
  pod 'Firebase/Messaging'
  pod 'Firebase/Crashlytics'

  target 'RoutineTests' do end
end

# Scripts
def fix_configuration(build_configuration)
  if build_configuration.name.downcase.include?('debug')
    build_configuration.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
    build_configuration.build_settings['VALIDATE_PRODUCT'] = 'NO'
    build_configuration.build_settings['DEBUG_INFORMATION_FORMAT'] = 'DWARF'
    build_configuration.build_settings['ENABLE_TESTABILITY'] = 'YES'
    build_configuration.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
    build_configuration.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
    build_configuration.build_settings['ENABLE_NS_ASSERTIONS'] = 'YES'
    build_configuration.build_settings['SWIFT_COMPILATION_MODE'] = 'singlefile'
    build_configuration.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = "$(inherited) DEBUG"
    build_configuration.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = "$(inherited) DEBUG=1"
  end
end

post_install do |pi|
  pi.pods_project.build_configurations.each do |build_configuration|
    # fix for cocoapods targets, to support multiple xcode configurations setup
    fix_configuration(build_configuration)
  end
  
  pi.pods_project.targets.each do |target|
    target.build_configurations.each do |build_configuration|
      # Remove extra warnings from xcode
      if build_configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 14.0
        build_configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
      
      # fix for cocoapods targets, to support multiple xcode configurations setup
      fix_configuration(build_configuration)
    end
  end
end
