class Socat < Formula
  desc "netcat on steroids"
  homepage "http://www.dest-unreach.org/socat/"
  url "http://www.dest-unreach.org/socat/download/socat-1.7.3.2.tar.gz"
  sha256 "ce3efc17e3e544876ebce7cd6c85b3c279fda057b2857fcaaf67b9ab8bdaf034"
  revision 1

  bottle do
    cellar :any
    sha256 "c8996f731d2c595a356b0b793568aee72543c249506b4a34ad782d8f0e5fa129" => :sierra
    sha256 "f8e75c8fb5e902928b25c27fd25279a922fa050e5f2bd329eef18e062e24481a" => :el_capitan
    sha256 "a5c5b28d9fbf0f52ab0d69dc7cbe44f23a58876e32791b69275d96a15703d3e9" => :yosemite
    sha256 "514417db542e8f485b078622ee8bcf613f3ad58a731d5b5597811fed28cd2700" => :x86_64_linux # glibc 2.19
  end

  devel do
    url "http://www.dest-unreach.org/socat/download/socat-2.0.0-b9.tar.gz"
    version "2.0.0-b9"
    sha256 "f9496ea44898d7707507a728f1ff16b887c80ada63f6d9abb0b727e96d5c281a"
  end

  depends_on "openssl@1.1"
  depends_on "readline"

  def install
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make", "install"
  end

  test do
    output = pipe_output("#{bin}/socat - tcp:www.google.com:80", "GET / HTTP/1.0\r\n\r\n")
    assert_match "HTTP/1.0", output.lines.first
  end
end
