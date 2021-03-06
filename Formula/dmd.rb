class Dmd < Formula
  desc "D programming language compiler for macOS"
  homepage "https://dlang.org/"

  stable do
    url "https://github.com/dlang/dmd/archive/v2.076.0.tar.gz"
    sha256 "5c65be56012d352f204cc692c6517c95f09518bde92d136e8f9ca5a75700e188"

    resource "druntime" do
      url "https://github.com/dlang/druntime/archive/v2.076.0.tar.gz"
      sha256 "8696070aa7d1e92e7ec130d58ff18b5ab35d701dc5299f1fb604140dee979c78"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos/archive/v2.076.0.tar.gz"
      sha256 "7e9ca04f18bc8711c7bfd0b44b0ba30d1c6356eaadeb54c812c3d9241200ad19"
    end

    resource "tools" do
      url "https://github.com/dlang/tools/archive/v2.076.0.tar.gz"
      sha256 "5f58dc6492e1abb539291a5fbf2bfb06eed818bd158912f090b55cd712c2a34a"
    end
  end

  bottle do
    sha256 "c58da079861e25df56ef88da13189f029fe93de528c1ad2ac66533fa97d8482d" => :sierra
    sha256 "13789fff9c570ffcad532fcac9ebafa59ea97f0e5dd65158436ed7d2d5ae5108" => :el_capitan
    sha256 "20461131f122509ceaccac8ab988aa88fa7f0411d332c3877b23c6152a9ad74b" => :yosemite
    sha256 "ce652dac2a1d57b6c477a67fd3fe574b8e347c650fa81f5914e6a1e954e2353e" => :x86_64_linux
  end

  head do
    url "https://github.com/dlang/dmd.git"

    resource "druntime" do
      url "https://github.com/dlang/druntime.git"
    end

    resource "phobos" do
      url "https://github.com/dlang/phobos.git"
    end

    resource "tools" do
      url "https://github.com/dlang/tools.git"
    end
  end

  depends_on "unzip" => :build unless OS.mac?

  def install
    make_args = ["INSTALL_DIR=#{prefix}", "MODEL=#{Hardware::CPU.bits}", "-f", "posix.mak"]

    system "make", "SYSCONFDIR=#{etc}", "TARGET_CPU=X86", "AUTO_BOOTSTRAP=1", "RELEASE=1", *make_args

    bin.install "src/dmd"
    prefix.install "samples"
    man.install Dir["docs/man/*"]

    make_args.unshift "DMD_DIR=#{buildpath}", "DRUNTIME_PATH=#{buildpath}/druntime", "PHOBOS_PATH=#{buildpath}/phobos"
    (buildpath/"druntime").install resource("druntime")
    (buildpath/"phobos").install resource("phobos")
    system "make", "-C", "druntime", *make_args
    system "make", "-C", "phobos", "VERSION=#{buildpath}/VERSION", *make_args

    resource("tools").stage do
      inreplace "posix.mak", "install: $(TOOLS) $(CURL_TOOLS)", "install: $(TOOLS) $(ROOT)/dustmite"
      system "make", "install", *make_args
    end

    (include/"dlang/dmd").install Dir["druntime/import/*"]
    cp_r ["phobos/std", "phobos/etc"], include/"dlang/dmd"
    lib.install Dir["druntime/lib/*", "phobos/**/libphobos2.a"]

    (buildpath/"dmd.conf").write <<-EOS.undent
      [Environment]
      DFLAGS=-I#{opt_include}/dlang/dmd -L-L#{opt_lib}
    EOS
    etc.install "dmd.conf"
  end

  # Previous versions of this formula may have left in place an incorrect
  # dmd.conf.  If it differs from the newly generated one, move it out of place
  # and warn the user.
  def install_new_dmd_conf
    conf = etc/"dmd.conf"

    # If the new file differs from conf, etc.install drops it here:
    new_conf = etc/"dmd.conf.default"
    # Else, we're already using the latest version:
    return unless new_conf.exist?

    backup = etc/"dmd.conf.old"
    opoo "An old dmd.conf was found and will be moved to #{backup}."
    mv conf, backup
    mv new_conf, conf
  end

  def post_install
    install_new_dmd_conf
  end

  test do
    system bin/"dmd", prefix/"samples/hello.d"
    system "./hello"
  end
end
