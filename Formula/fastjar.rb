class Fastjar < Formula
  desc "Implementation of Sun's jar tool"
  homepage "https://sourceforge.net/projects/fastjar/"
  url "https://downloads.sourceforge.net/project/fastjar/fastjar/0.94/fastjar-0.94.tar.gz"
  sha256 "5a217fc3e3017efb18fd1316b38d2aaa7370280fcf5732ad8fff7e27ec867b95"

  bottle do
    cellar :any_skip_relocation
    sha256 "5d03ecf7d89b4c9cd3ca25735692b77f55ae7df83bdb4073e013f5361256c689" => :sierra
    sha256 "996937a030b443cee74e1de1945e3199022fc27514cf9925c332ed5d5804c80a" => :el_capitan
    sha256 "07dd91fef374251b87b1a2987089234a3da225b79313afa4d8a7f502d1a51aae" => :yosemite
    sha256 "4e1d46c61723a1babbba0841b9dbde5c33388e107202f6ca292adc23ab7149a3" => :mavericks
    sha256 "d5f4c6b38e23aac6271d80145474c1b4f985beb373988e5b1cb9e631269978e0" => :x86_64_linux # glibc 2.19
  end

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/fastjar", "-V"
    system "#{bin}/grepjar", "-V"
  end
end
