class FfmpegAT28 < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-2.8.11.tar.bz2"
  sha256 "9987e0f6b1f66311390f807a0c18ad9c90652b5097cff17b3dcbeabdd89f8d32"

  bottle do
    sha256 "e031f023b70ad0e7357dbfaf36bc5a9de82c5f678c5d41f39ed5f76edd6aaa61" => :sierra
    sha256 "dd85334c99ee8f2af3cf57a11d8af01c63e2ef3127742b141915713d49868e0a" => :el_capitan
    sha256 "991871ed17f2912831eb9157e912a1c6748ba2f573ac982a5ad8bf2932313ac3" => :yosemite
    sha256 "9bda8713d8a170fc1be39ce02493445d19ca6f65d6ecaed46af1357ab647517e" => :x86_64_linux # glibc 2.19
  end

  keg_only :versioned_formula

  option "without-x264", "Disable H.264 encoder"
  option "without-lame", "Disable MP3 encoder"
  option "without-libvo-aacenc", "Disable VisualOn AAC encoder"
  option "without-xvid", "Disable Xvid MPEG-4 video encoder"
  option "without-qtkit", "Disable deprecated QuickTime framework"

  option "with-rtmpdump", "Enable RTMP protocol"
  option "with-libass", "Enable ASS/SSA subtitle format"
  option "with-opencore-amr", "Enable Opencore AMR NR/WB audio format"
  option "with-openjpeg", "Enable JPEG 2000 image format"
  option "with-openssl", "Enable SSL support"
  option "with-libssh", "Enable SFTP protocol via libssh"
  option "with-schroedinger", "Enable Dirac video format"
  option "with-ffplay", "Enable FFplay media player"
  option "with-tools", "Enable additional FFmpeg tools"
  option "with-fdk-aac", "Enable the Fraunhofer FDK AAC library"
  option "with-libvidstab", "Enable vid.stab support for video stabilization"
  option "with-x265", "Enable x265 encoder"
  option "with-libsoxr", "Enable the soxr resample library"
  option "with-webp", "Enable using libwebp to encode WEBP images"
  option "with-zeromq", "Enable using libzeromq to receive commands sent through a libzeromq client"
  option "with-snappy", "Enable Snappy library"
  option "with-dcadec", "Enable dcadec library"

  depends_on "pkg-config" => :build

  # manpages won't be built without texi2html
  depends_on "texi2html" => :build
  depends_on "yasm" => :build

  depends_on "x264" => :recommended
  depends_on "lame" => :recommended
  depends_on "libvo-aacenc" => :recommended
  depends_on "xvid" => :recommended

  depends_on "faac" => :optional
  depends_on "fontconfig" => :optional
  depends_on "freetype" => :optional
  depends_on "theora" => :optional
  depends_on "libvorbis" => :optional
  depends_on "libvpx" => :optional
  depends_on "rtmpdump" => :optional
  depends_on "opencore-amr" => :optional
  depends_on "libass" => :optional
  depends_on "openjpeg" => :optional
  depends_on "sdl" if build.with? "ffplay"
  depends_on "snappy" => :optional
  depends_on "speex" => :optional
  depends_on "schroedinger" => :optional
  depends_on "fdk-aac" => :optional
  depends_on "opus" => :optional
  depends_on "frei0r" => :optional
  depends_on "libcaca" => :optional
  depends_on "libbluray" => :optional
  depends_on "libsoxr" => :optional
  depends_on "libquvi" => :optional
  depends_on "libvidstab" => :optional
  depends_on "x265" => :optional
  depends_on "openssl" => :optional
  depends_on "libssh" => :optional
  depends_on "webp" => :optional
  depends_on "zeromq" => :optional
  depends_on "libbs2b" => :optional
  depends_on "dcadec" => :optional

  def install
    # Fixes "dyld: lazy symbol binding failed: Symbol not found: _clock_gettime"
    if MacOS.version == "10.11" && MacOS::Xcode.installed? && MacOS::Xcode.version >= "8.0"
      inreplace %w[libavdevice/v4l2.c libavutil/time.c], "HAVE_CLOCK_GETTIME",
                                                         "UNDEFINED_GIBBERISH"
    end

    args = ["--prefix=#{prefix}",
            "--enable-shared",
            "--enable-pthreads",
            "--enable-gpl",
            "--enable-version3",
            "--enable-hardcoded-tables",
            "--enable-avresample",
            "--cc=#{ENV.cc}",
            "--host-cflags=#{ENV.cflags}",
            "--host-ldflags=#{ENV.ldflags}"]

    args << "--enable-opencl" if MacOS.version > :lion

    args << "--enable-libx264" if build.with? "x264"
    args << "--enable-libmp3lame" if build.with? "lame"
    args << "--enable-libvo-aacenc" if build.with? "libvo-aacenc"
    args << "--enable-libxvid" if build.with? "xvid"
    args << "--enable-libsnappy" if build.with? "snappy"

    args << "--enable-libfontconfig" if build.with? "fontconfig"
    args << "--enable-libfreetype" if build.with? "freetype"
    args << "--enable-libtheora" if build.with? "theora"
    args << "--enable-libvorbis" if build.with? "libvorbis"
    args << "--enable-libvpx" if build.with? "libvpx"
    args << "--enable-librtmp" if build.with? "rtmpdump"
    args << "--enable-libopencore-amrnb" << "--enable-libopencore-amrwb" if build.with? "opencore-amr"
    args << "--enable-libfaac" if build.with? "faac"
    args << "--enable-libass" if build.with? "libass"
    args << "--enable-ffplay" if build.with? "ffplay"
    args << "--enable-libssh" if build.with? "libssh"
    args << "--enable-libspeex" if build.with? "speex"
    args << "--enable-libschroedinger" if build.with? "schroedinger"
    args << "--enable-libfdk-aac" if build.with? "fdk-aac"
    args << "--enable-openssl" if build.with? "openssl"
    args << "--enable-libopus" if build.with? "opus"
    args << "--enable-frei0r" if build.with? "frei0r"
    args << "--enable-libcaca" if build.with? "libcaca"
    args << "--enable-libsoxr" if build.with? "libsoxr"
    args << "--enable-libquvi" if build.with? "libquvi"
    args << "--enable-libvidstab" if build.with? "libvidstab"
    args << "--enable-libx265" if build.with? "x265"
    args << "--enable-libwebp" if build.with? "webp"
    args << "--enable-libzmq" if build.with? "zeromq"
    args << "--enable-libbs2b" if build.with? "libbs2b"
    args << "--enable-libdcadec" if build.with? "dcadec"
    args << "--disable-indev=qtkit" if build.without? "qtkit"

    if build.with? "openjpeg"
      args << "--enable-libopenjpeg"
      args << "--disable-decoder=jpeg2000"
      args << "--extra-cflags=" + `pkg-config --cflags libopenjpeg`.chomp
    end

    # These librares are GPL-incompatible, and require ffmpeg be built with
    # the "--enable-nonfree" flag, which produces unredistributable libraries
    if %w[faac fdk-aac openssl].any? { |f| build.with? f }
      args << "--enable-nonfree"
    end

    # A bug in a dispatch header on 10.10, included via CoreFoundation,
    # prevents GCC from building VDA support. GCC has no problems on
    # 10.9 and earlier.
    # See: https://github.com/Homebrew/homebrew/issues/33741
    if MacOS.version < :yosemite || ENV.compiler == :clang
      args << "--enable-vda"
    else
      args << "--disable-vda"
    end

    # For 32-bit compilation under gcc 4.2, see:
    # https://trac.macports.org/ticket/20938#comment:22
    ENV.append_to_cflags "-mdynamic-no-pic" if Hardware::CPU.is_32_bit? && Hardware::CPU.intel? && ENV.compiler == :clang

    system "./configure", *args

    if MacOS.prefer_64_bit?
      inreplace "config.mak" do |s|
        shflags = s.get_make_var "SHFLAGS"
        if shflags.gsub!(" -Wl,-read_only_relocs,suppress", "")
          s.change_make_var! "SHFLAGS", shflags
        end
      end
    end

    system "make", "install"

    if build.with? "tools"
      system "make", "alltools"
      bin.install Dir["tools/*"].select { |f| File.executable? f }
    end
  end

  def caveats
    if build.without? "faac" then <<-EOS.undent
      FFmpeg has been built without libfaac for licensing reasons;
      libvo-aacenc is used by default.
      To install with libfaac, you can:
        brew reinstall ffmpeg28 --with-faac

      You can also use the experimental FFmpeg encoder, libfdk-aac, or
      libvo_aacenc to encode AAC audio:
        ffmpeg -i input.wav -c:a aac -strict experimental output.m4a
      Or:
        brew reinstall ffmpeg28 --with-fdk-aac
        ffmpeg -i input.wav -c:a libfdk_aac output.m4a
      EOS
    end
  end

  test do
    # Create an example mp4 file
    system "#{bin}/ffmpeg", "-y", "-filter_complex",
        "testsrc=rate=1:duration=1", "#{testpath}/video.mp4"
    assert (testpath/"video.mp4").exist?
  end
end
