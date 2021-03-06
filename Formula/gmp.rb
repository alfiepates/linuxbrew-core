class Gmp < Formula
  desc "GNU multiple precision arithmetic library"
  homepage "https://gmplib.org/"
  url "https://gmplib.org/download/gmp/gmp-6.1.2.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz"
  sha256 "87b565e89a9a684fe4ebeeddb8399dce2599f9c9049854ca8c0dfbdea0e21912"

  bottle do
    cellar :any
    rebuild 1
    sha256 "cd4a916966007092af477a76655cc1f66546d00bf5e581a5dfef334f8436aeb0" => :sierra
    sha256 "01b24de832db7aa24ee14159feb5a16e0e3e18932e6f38d221331bb45feb6a1a" => :el_capitan
    sha256 "3752709f0bab1999fa9d5407bcd3135a873b48fc34d5e6ea123fd68c4cf3644d" => :yosemite
    sha256 "ff7e7d5c74ac58c6f15369eb2d351603e1e5a49daec135b216a0355c6de3c680" => :x86_64_linux
  end

  depends_on "m4" unless OS.mac?

  option :cxx11

  def install
    ENV.cxx11 if build.cxx11?
    args = %W[--prefix=#{prefix} --enable-cxx]

    if OS.mac?
      args << "--build=core2-apple-darwin#{`uname -r`.to_i}" if build.bottle?
    elsif Hardware::CPU.intel? && Hardware::CPU.is_32_bit?
      args << "ABI=32"
    end

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <gmp.h>
      #include <stdlib.h>

      int main() {
        mpz_t i, j, k;
        mpz_init_set_str (i, "1a", 16);
        mpz_init (j);
        mpz_init (k);
        mpz_sqrtrem (j, k, i);
        if (mpz_get_si (j) != 5 || mpz_get_si (k) != 1) abort();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lgmp", "-o", "test"
    system "./test"
  end
end
