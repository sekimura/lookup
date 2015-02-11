require 'formula'

LOOKUP_VERSION = "1.1.0"

class Lookup < Formula
  homepage "https://github.com/sekimura/lookup"
  url "https://github.com/sekimura/lookup/archive/v#{LOOKUP_VERSION}.zip"
  sha1 "491bc9d50cd58fa7684015637eaaf6d2471d594d"
  version LOOKUP_VERSION

  def install
    system "install", "lookup", "#{prefix}/lookup"
    system "ln", "-sf", "#{prefix}/lookup", "/usr/local/bin/lookup"
  end
end
