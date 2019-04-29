use_frameworks!

target ‘ReactiveWeather’ do
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RxAlamofire'
    pod 'SwiftyJSON'
    pod 'Kingfisher'
end

# enable tracing resources

post_install do |installer|
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
