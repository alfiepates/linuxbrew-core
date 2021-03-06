class Goffice < Formula
  desc "Gnumeric spreadsheet program"
  homepage "https://developer.gnome.org/goffice/"
  url "https://download.gnome.org/sources/goffice/0.10/goffice-0.10.35.tar.xz"
  sha256 "c19001afca09dc5446e06605a113d81a57124018a09c5889aeebba16cf1d5738"

  bottle do
    sha256 "cec7000c218b139929f572e126c5f6b20acec58e1e2059513ca9e0b2b31de622" => :sierra
    sha256 "60abc1461b63b81854a83de1f5d511e0bae3979eb4c005701ab420430d7f60a4" => :el_capitan
    sha256 "8d2425d629338d26aecb057b43b41732fffe32b75d82d2cf8ec1f39378c4df07" => :yosemite
    sha256 "4e4a08edbcbaec2f5cd4a9efe9ed5da1c307ae87d07a021ad85ce41528fe64ea" => :x86_64_linux # glibc 2.19
  end

  head do
    url "https://github.com/GNOME/goffice.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gtk-doc" => :build
    depends_on "libtool" => :build
  end

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "atk"
  depends_on "cairo"
  depends_on "gdk-pixbuf"
  depends_on "gettext"
  depends_on "gtk+3"
  depends_on "libgsf"
  depends_on "librsvg"
  depends_on "pango"
  depends_on "pcre"
  depends_on "libxslt" unless OS.mac?

  def install
    args = %W[--disable-dependency-tracking --prefix=#{prefix}]
    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <goffice/goffice.h>
      int main()
      {
          void
          libgoffice_init (void);
          void
          libgoffice_shutdown (void);
          return 0;
      }
    EOS
    libxml2 = OS.mac? ? "/usr/include/libxml2" : "#{Formula["libxml2"].opt_include}/libxml2"
    system ENV.cc, "-I#{include}/libgoffice-0.10",
           "-I#{Formula["glib"].opt_include}/glib-2.0",
           "-I#{Formula["glib"].opt_lib}/glib-2.0/include",
           "-I#{Formula["libgsf"].opt_include}/libgsf-1",
           "-I#{libxml2}",
           "-I#{Formula["gtk+3"].opt_include}/gtk-3.0",
           "-I#{Formula["pango"].opt_include}/pango-1.0",
           "-I#{Formula["cairo"].opt_include}/cairo",
           "-I#{Formula["gdk-pixbuf"].opt_include}/gdk-pixbuf-2.0",
           "-I#{Formula["atk"].opt_include}/atk-1.0",
           testpath/"test.c", "-o", testpath/"test"
    system "./test"
  end
end
