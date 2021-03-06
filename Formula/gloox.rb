class Gloox < Formula
  desc "C++ Jabber/XMPP library that handles the low-level protocol"
  homepage "https://camaya.net/gloox/"
  url "https://camaya.net/download/gloox-1.0.20.tar.bz2"
  sha256 "0243086c0f4f0440d6d8e55705f83249a4463a1d75a034be42b5312e8886dea8"

  bottle do
    cellar :any
    sha256 "8268b106a2de45233f339630793ebdb46c501925faa758f0d61eb7485ced1c87" => :sierra
    sha256 "7b0dafa8d25adac387410d0bd064c2645d4fb8826c0b24b840c71e3e783eaa3b" => :el_capitan
    sha256 "12fa240ab11bad334840099b0a8574b6cce0064647b06bb433f3600669bd6cda" => :yosemite
    sha256 "d0e17df776f6c8554363dcefdd2cb331eba426472ec3ef65b03f4c92121d862c" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "openssl" => :recommended
  depends_on "gnutls" => :optional
  depends_on "libidn" => :optional

  def install
    args = %W[
      --prefix=#{prefix}
      --with-zlib
      --disable-debug
    ]

    if build.with? "gnutls"
      args << "--with-gnutls=yes"
    else
      args << "--with-openssl=#{Formula["openssl"].opt_prefix}"
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    system bin/"gloox-config", "--cflags", "--libs", "--version"
  end
end
