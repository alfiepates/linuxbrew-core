class Flow < Formula
  desc "Static type checker for JavaScript"
  homepage "https://flowtype.org/"
  url "https://github.com/facebook/flow/archive/v0.54.1.tar.gz"
  sha256 "90073f01578a967f97f564b039d63680c850e90a6b95e0edde4513e36e141fe0"
  head "https://github.com/facebook/flow.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "9c40124399b90f016d9f7547b41af341afc090cef3cb58510555c0fd24fdeb33" => :sierra
    sha256 "5571f4ac932eb7af27ebc386f2d0898961b1b2eb758de123e60e7f8e71c92926" => :el_capitan
    sha256 "24bf5e452af4e3f34330ea424970798b084983187308ad6d35af256440003e9e" => :yosemite
    sha256 "923cd0f231e61617737d4ebfbd413b349fa53e9402dd2b89d8e40d63a31b8bbe" => :x86_64_linux
  end

  depends_on "ocaml" => :build
  depends_on "opam" => :build
  unless OS.mac?
    depends_on "m4" => :build
    depends_on "unzip" => :build
    depends_on "elfutils"
  end

  # Fix "compilation of ocaml-migrate-parsetree failed"
  # Reported 24 Jul 2017 https://github.com/ocaml/opam/issues/3007
  patch :DATA

  def install
    system "make", "all-homebrew"

    bin.install "bin/flow"

    bash_completion.install "resources/shell/bash-completion" => "flow-completion.bash"
    zsh_completion.install_symlink bash_completion/"flow-completion.bash" => "_flow"
  end

  test do
    system "#{bin}/flow", "init", testpath
    (testpath/"test.js").write <<-EOS.undent
      /* @flow */
      var x: string = 123;
    EOS
    expected = /Found 1 error/
    assert_match expected, shell_output("#{bin}/flow check #{testpath}", 2)
  end
end

__END__
diff --git a/Makefile b/Makefile
index 515e581..8886bf6 100644
--- a/Makefile
+++ b/Makefile
@@ -174,8 +174,8 @@ all-homebrew:
	export OPAMYES="1"; \
	export FLOW_RELEASE="1"; \
	opam init --no-setup && \
-	opam pin add flowtype . && \
-	opam install flowtype --deps-only && \
+	opam pin add -n flowtype . && \
+	opam config exec -- opam install flowtype --deps-only && \
	opam config exec -- make

 clean:
