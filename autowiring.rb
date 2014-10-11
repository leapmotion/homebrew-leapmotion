require "formula"

class Autowiring < Formula
  homepage "http://autowiring.io/"
  url "https://github.com/leapmotion/autowiring/archive/release-0.2.3.tar.gz"
  sha1 "8d55ec6d479376a8a310ccf7b7a3bbbcbca3677a"

  depends_on "cmake" => :build
  depends_on "boost" => :recommended

  option "without-libcxx", "Mac 10.6 and earlier ships without the latest version of the C++ standard
library, libc++.  Customers intending to target these older machines must instead
link to libstdc++.  This linkage choice changes the available headers due to
reduced compiler support, and so Autowiring will attempt to fall back on Boost
in order to provide the same level of service"

  def install
    # Command line args to pass to CMake
    args = [
      "-DCMAKE_INSTALL_PREFIX=#{prefix}"
    ]

    # Turn autowiring off if building without boost
    args << "-DAUTOWIRING_BUILD_AUTONET=OFF" if build.without? "boost"

    # Check if we want a pre-C++11 build
    args << "-DUSE_LIBCXX=OFF" if build.without? "libcxx"

    # Build Debug
    system "cmake", ".", "-DCMAKE_BUILD_TYPE=Debug", *args
    system "make -j 8 || make"
    system "make install"

    # Build release
    system "cmake", ".", "-DCMAKE_BUILD_TYPE=Release", *args
    system "make -j 8 || make"
    system "make install"

    # Link CMake config for autowiring
    (share/'autowiring').install prefix/'cmake/autowiring-config.cmake'
    (share/'autowiring').install prefix/'cmake/autowiring-configVersion.cmake'
  end

  test do
    # Check if cmake can find installed autowiring
    (testpath/"CMakeLists.txt").write("find_package(autowiring)")
    system "cmake", "."
  end
end
