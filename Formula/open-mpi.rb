class OpenMpi < Formula
  desc "High performance message passing library"
  homepage "https://www.open-mpi.org/"
  url "https://www.open-mpi.org/software/ompi/v2.1/downloads/openmpi-2.1.1.tar.bz2"
  sha256 "bd7badd4ff3afa448c0d7f3ca0ee6ce003b957e9954aa87d8e4435759b5e4d16"

  bottle do
    sha256 "15d3d18ad8e4096b670fd9fee3f196cee0bbea4db663cab4eb58a24927daa1cf" => :sierra
    sha256 "82b89bc9302d9ca10cf0dfa0a53a8298aa4cbb9a84b92139e5ca2a7583499947" => :el_capitan
    sha256 "4b0437cdcf8e32cf205fb4fc3755eb8a8bb7e35b93d52070e9d3390d2e57d5fa" => :yosemite
    sha256 "974ca1eaf14fedfd8a761305ebb9a35b9889b571e7bbb029dafafa5046450e77" => :x86_64_linux # glibc 2.19
  end

  head do
    url "https://github.com/open-mpi/ompi.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  option "with-mpi-thread-multiple", "Enable MPI_THREAD_MULTIPLE"
  option "with-cxx-bindings", "Enable C++ MPI bindings (deprecated as of MPI-3.0)"
  option :cxx11

  deprecated_option "disable-fortran" => "without-fortran"
  deprecated_option "enable-mpi-thread-multiple" => "with-mpi-thread-multiple"

  depends_on :fortran => :recommended
  depends_on :java => :optional
  depends_on "libevent"

  conflicts_with "mpich", :because => "both install mpi__ compiler wrappers"
  conflicts_with "lcdf-typetools", :because => "both install same set of binaries."

  def install
    ENV.cxx11 if build.cxx11?

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-ipv6
      --with-libevent=#{Formula["libevent"].opt_prefix}
      --with-sge
    ]
    args << "--with-platform-optimized" if build.head?
    args << "--disable-mpi-fortran" if build.without? "fortran"
    args << "--enable-mpi-thread-multiple" if build.with? "mpi-thread-multiple"
    args << "--enable-mpi-java" if build.with? "java"
    args << "--enable-mpi-cxx" if build.with? "cxx-bindings"

    system "./autogen.pl" if build.head?
    system "./configure", *args
    system "make", "all"
    system "make", "check"
    system "make", "install"

    # If Fortran bindings were built, there will be stray `.mod` files
    # (Fortran header) in `lib` that need to be moved to `include`.
    include.install Dir["#{lib}/*.mod"] if build.with? "fortran"
  end

  test do
    (testpath/"hello.c").write <<-EOS.undent
      #include <mpi.h>
      #include <stdio.h>

      int main()
      {
        int size, rank, nameLen;
        char name[MPI_MAX_PROCESSOR_NAME];
        MPI_Init(NULL, NULL);
        MPI_Comm_size(MPI_COMM_WORLD, &size);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        MPI_Get_processor_name(name, &nameLen);
        printf("[%d/%d] Hello, world! My name is %s.\\n", rank, size, name);
        MPI_Finalize();
        return 0;
      }
    EOS
    system bin/"mpicc", "hello.c", "-o", "hello"
    system "./hello"
    system bin/"mpirun", "-np", "4", "./hello"
    (testpath/"hellof.f90").write <<-EOS.undent
      program hello
      include 'mpif.h'
      integer rank, size, ierror, tag, status(MPI_STATUS_SIZE)
      call MPI_INIT(ierror)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierror)
      call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierror)
      print*, 'node', rank, ': Hello Fortran world'
      call MPI_FINALIZE(ierror)
      end
    EOS
    system bin/"mpif90", "hellof.f90", "-o", "hellof"
    system "./hellof"
    system bin/"mpirun", "-np", "4", "./hellof"
  end
end
