target 'Gradientor' do
  use_frameworks!

  pod 'AdFooter', git: 'https://gitlab.com/tnantoka/AdFooter.git', commit: '782d2aff5b8caa091e8964a42dd84ce337eb8029'
  pod 'ChameleonFramework/Swift', git: 'https://github.com/ViccAlexander/Chameleon.git'
  pod 'Eureka', '4.3.1'
  pod "IoniconsKit", git: 'https://github.com/anzfactory/IoniconsKit.git'
  pod 'PKHUD', '5.2.1'
  pod 'ReSwift'
  pod 'RFAboutView-Swift', git: 'https://github.com/arno608rw/RFAboutView-Swift.git'
  pod 'RxSwift', '4.5.0'
  pod 'RxCocoa', '4.5.0'
  pod 'SnapKit', '4.2.0'

  target 'GradientorTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  require 'fileutils'
  FileUtils.cp_r 'Pods/Target Support Files/Pods-Gradientor/Pods-Gradientor-acknowledgements.plist', 'Gradientor/Acknowledgements.plist', remove_destination: true

  installer.pods_project.targets.each do |target|
    if target.name == 'RxSwift'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
        end
      end
    end
  end
end

