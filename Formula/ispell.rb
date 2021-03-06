class Ispell < Formula
  desc "International Ispell"
  homepage "https://lasr.cs.ucla.edu/geoff/ispell.html"
  url "https://www.cs.hmc.edu/~geoff/tars/ispell-3.4.00.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/i/ispell/ispell_3.4.00.orig.tar.gz"
  sha256 "5dc42e458635f218032d3ae929528e5587b1e7247564f0e9f9d77d5ccab7aec2"

  bottle do
    sha256 "697a51b2d4e5d568ef18fdfe5943691a534145829522e3d4bb7d25f2f7978c9f" => :sierra
    sha256 "81d9f6f9aca0f92ba3bece2ad22d0b0bca29c719304c6c5e8e59b02a3c8763da" => :el_capitan
    sha256 "ff46baf7aa6daf42fddde68897bd80dbb073922b4556c502e7b0072656b48498" => :yosemite
    sha256 "f1ee90dcc76682d17c2b758d2a896493448753acc0e556e9b0c8bf7ec0f552df" => :mavericks
    sha256 "dbbaabbc715f6f16dfb9f2cd05755a88e471b92c63d7f87f79a940a5df8dadfb" => :mountain_lion
    sha256 "c8bbcdc12d3e90e63949f6f284d8e8ebc2c723ed53251fe4619d600896345bfb" => :x86_64_linux # glibc 2.19
  end

  depends_on "ncurses" unless OS.mac?

  def install
    ENV.deparallelize

    # No configure script, so do this all manually
    cp "local.h.macos", "local.h"
    chmod 0644, "local.h"
    inreplace "local.h" do |s|
      s.gsub! "/usr/local", prefix
      s.gsub! "/man/man", "/share/man/man"
      s.gsub! "/lib", "/lib/ispell"
    end

    chmod 0644, "correct.c"
    inreplace "correct.c", "getline", "getline_ispell"

    system "make", "config.sh"
    chmod 0644, "config.sh"
    inreplace "config.sh", "/usr/share/dict", "#{share}/dict"

    (lib/"ispell").mkpath
    system "make", "install"
  end

  test do
    assert_equal "BOTHER BOTHE/R BOTH/R",
                 `echo BOTHER | #{bin}/ispell -c`.chomp
  end
end
