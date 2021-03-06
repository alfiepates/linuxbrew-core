class Htmlcleaner < Formula
  desc "HTML parser written in Java"
  homepage "https://htmlcleaner.sourceforge.io"
  url "https://downloads.sourceforge.net/project/htmlcleaner/htmlcleaner/htmlcleaner%20v2.18/htmlcleaner-2.18-src.zip"
  sha256 "d16250d038b5adc2a343fb322827575ddca95ba84887be659733bf753e7ef15b"

  bottle do
    cellar :any_skip_relocation
    sha256 "87838ab8f3acda2911416178fd1bdf11d37ac7d3b6e21007f6218d1ad7e7139b" => :sierra
    sha256 "cc0afb1dd3c56cd78700138590142baa370480ff979ff757a4b5f7a18f66219c" => :el_capitan
    sha256 "2082bbebc107e771ed502971cec401c9b23b5c977c2fcc9324cd54c28f78f5a8" => :yosemite
    sha256 "89e99224dc1c82bf58576181e285c7ac2bc057e52bf9cccb86a4e35e19a54849" => :x86_64_linux # glibc 2.19
  end

  depends_on "maven" => :build
  depends_on :java => "1.8+"

  def install
    system "mvn", "--log-file", "build-output.log", "clean", "package"
    libexec.install Dir["target/htmlcleaner-*.jar"]
    bin.write_jar_script "#{libexec}/htmlcleaner-#{version}.jar", "htmlcleaner"
  end

  test do
    path = testpath/"index.html"
    path.write "<html>"
    assert_match "</html>", shell_output("#{bin}/htmlcleaner src=#{path}")
  end
end
