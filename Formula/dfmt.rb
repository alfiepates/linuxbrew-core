class Dfmt < Formula
  desc "Formatter for D source code"
  homepage "https://github.com/dlang-community/dfmt"
  url "https://github.com/dlang-community/dfmt.git",
      :tag => "v0.5.0",
      :revision => "fef85e388a41add75020675ab33ed7e55c3efe85"

  head "https://github.com/dlang-community/dfmt.git", :shallow => false

  bottle do
    sha256 "08ce677f6ae697ea33e29d4ecff0e419cbe71b065b8a24cb13bc65a4c5834b40" => :sierra
    sha256 "745cc85d47967fd74ad25a08dd763f028440a2c5811730c2b2c6643d7f5236b6" => :el_capitan
    sha256 "66fe1b25802b529a08f7a46e0b043fdf06e64c9fe1a48dbc04293954187b65a1" => :yosemite
    sha256 "a201c83a77064aa017f718d82c5f74f6a480b4b7a82b885a0ad354e5504a002a" => :x86_64_linux # glibc 2.19
  end

  depends_on "dmd" => :build

  def install
    system "make"
    bin.install "bin/dfmt"
  end

  test do
    (testpath/"test.d").write <<-EOS.undent
    import std.stdio; void main() { writeln("Hello, world without explicit compilations!"); }
    EOS

    expected = <<-EOS.undent
    import std.stdio;

    void main()
    {
        writeln("Hello, world without explicit compilations!");
    }
    EOS

    system "#{bin}/dfmt", "-i", "test.d"

    assert_equal expected, (testpath/"test.d").read
  end
end
