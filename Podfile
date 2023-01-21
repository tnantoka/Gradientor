target 'Gradientor' do
  use_frameworks!

  pod 'AdFooter', git: 'https://gitlab.com/tnantoka/AdFooter.git', commit: '970ab1353912a43436b3198683dbded2e3fa7bb8'
  pod 'ChameleonFramework/Swift', git: 'https://github.com/redroostertech/Chameleon', commit: '56f36fbc69ad6389243f556a1faed4581f4e1df6'
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

