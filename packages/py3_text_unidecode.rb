require 'buildsystems/python'

class Py3_text_unidecode < Python
  description 'Text-unicode is the most basic Text::Unidecode port.'
  homepage 'https://github.com/kmike/text-unidecode/'
  @_ver = '1.3'
  version "#{@_ver}-py3.12"
  license 'MIT'
  compatibility 'all'
  source_url 'https://github.com/kmike/text-unidecode.git'
  git_hashtag @_ver
  binary_compression 'tar.zst'

  binary_sha256({
    aarch64: 'fc5b03440a6fb6c45e0b2b442534cacf2b77168888e9df2f53376b1f72abb240',
     armv7l: 'fc5b03440a6fb6c45e0b2b442534cacf2b77168888e9df2f53376b1f72abb240',
       i686: '1d793188d215a8eacd84c2323af0cb424761c2ccf1d9f78bfc5f3292730b6c53',
     x86_64: 'b1aef834e86f06370b8d8bd1f9c2356d763376ad9e2b909075fa3439ab004e89'
  })

  depends_on 'python3' => :build
end
