WORKSPACE = 'VENCore.xcworkspace'
SCHEME = 'VENCore'

desc 'Run the tests'
task :test do
  require_binary 'bundle', 'gem install bundler'
  sh 'bundle exec pod repo update --silent'
  sh 'bundle exec pod install'

  require_binary 'xcodebuild', 'brew install xcodebuild'
  require_binary 'xcpretty', 'bundle install'
  sh "xcodebuild test -workspace #{WORKSPACE} -scheme #{SCHEME} -destination 'platform=iOS Simulator,name=iPhone 4s,OS=latest' | bundle exec xcpretty --color; exit ${PIPESTATUS[0]}"
end

task :default => :test

desc 'Print test coverage of the last test run.'
task :coverage do
  require_binary 'slather', 'bundle install'
  sh 'slather coverage -s'
end


private

def require_binary(binary, install)
  if `which #{binary}`.length == 0
    fail "\nERROR: #{binary} isn't installed. Please install #{binary} with the following command:\n\n    $ #{install}\n\n"
  end
end
