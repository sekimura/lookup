require 'formula'

LOOKUP_VERSION = "1.3.0"

class Lookup < Formula
  homepage "https://github.com/sekimura/lookup"
  url "https://github.com/sekimura/lookup/archive/v#{LOOKUP_VERSION}.zip"
  sha1 "133d1d6960409b400e1bd4dc78e7587b184b7cbf"
  version LOOKUP_VERSION

  def install
    system "install", "lookup", "#{prefix}/lookup"
    system "ln", "-sf", "#{prefix}/lookup", "/usr/local/bin/lookup"
  end
end
