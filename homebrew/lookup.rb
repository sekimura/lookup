require 'formula'

LOOKUP_VERSION = "1.2.0"

class Lookup < Formula
  homepage "https://github.com/sekimura/lookup"
  url "https://github.com/sekimura/lookup/archive/v#{LOOKUP_VERSION}.zip"
  sha1 "3f8c428f4bc3b18ce7165f2382da9a5c79aa4441"
  version LOOKUP_VERSION

  def install
    system "install", "lookup", "#{prefix}/lookup"
    system "ln", "-sf", "#{prefix}/lookup", "/usr/local/bin/lookup"
  end
end
