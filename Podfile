target 'Gradientor' do
  use_frameworks!

  pod 'AdFooter', git: 'https://gitlab.com/tnantoka/AdFooter.git'
  pod 'ChameleonFramework/Swift', git: 'https://github.com/redroostertech/Chameleon', commit: '56f36fbc69ad6389243f556a1faed4581f4e1df6'
  pod 'Eureka', '4.3.1'
  pod "IoniconsKit", git: 'https://github.com/anzfactory/IoniconsKit.git'
  pod 'PKHUD', '5.2.1'
  pod 'ReSwift'
  pod 'RFAboutView-Swift', git: 'https://github.com/arno608rw/RFAboutView-Swift.git'
  pod 'RxSwift', '5.1.3'
  pod 'RxCocoa', '5.1.3'
  pod 'SnapKit', '4.2.0'

  target 'GradientorTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  require 'fileutils'
  FileUtils.cp_r 'Pods/Target Support Files/Pods-Gradientor/Pods-Gradientor-acknowledgements.plist', 'Gradientor/Acknowledgements.plist', remove_destination: true

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if target.name == 'RxSwift' && config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
      end

      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 11.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end
end

