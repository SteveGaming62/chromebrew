require 'buildsystems/ruby'

class Ruby_pry_byebug < RUBY
  description 'Adds step-by-step debugging and stack navigation capabilities to pry using byebug.'
  homepage 'https://github.com/deivid-rodriguez/pry-byebug'
  version '3.10.1-ruby-3.3'
  license 'MIT'
  compatibility 'all'
  source_url 'SKIP'

  depends_on 'ruby_pry' # L
  conflicts_ok
  no_compile_needed
end
