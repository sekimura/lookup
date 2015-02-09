require 'formula'

LOOKUP_VERSION = "1.0.0"

class Lookup < Formula
  homepage "https://github.com/sekimura/lookup"
  url "https://github.com/sekimura/lookup/archive/v#{LOOKUP_VERSION}.zip"
  sha1 "9bc735bf8e5ca56c60e456c62cecdaad0934fdf3"
  version LOOKUP_VERSION
  head "https://github.com/sekimura/lookup.git", :branch => "master"

  def install
    system "install", "lookup", "#{prefix}/lookup"
    system "ln", "-sf", "#{prefix}/lookup", "/usr/local/bin/lookup"
  end
end
