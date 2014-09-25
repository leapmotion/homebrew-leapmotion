require "formula"

class Autowiring < Formula
  homepage "http://autowiring.io/"
  url "https://github.com/leapmotion/autowiring/archive/v0.1.1.tar.gz"
  sha1 "6047ba13ecf3cb421aee568b29d0fb93df680983"

  depends_on "cmake" => :build
  depends_on "boost" => :recommended

  option "with-debug", "Build a debug build"
  option "without-libcxx", "Mac 10.6 and earlier ships without the latest version of the C++ standard
library, libc++.  Customers intending to target these older machines must instead
link to libstdc++.  This linkage choice changes the available headers due to
reduced compiler support, and so Autowiring will attempt to fall back on Boost
in order to provide the same level of service"

  def install
    args = [
      "-DCMAKE_INSTALL_PREFIX=#{prefix}"
    ]

    # Check if debug build
    if build.with? "debug"
      args << "-DCMAKE_BUILD_TYPE=Debug"
    else
      args << "-DCMAKE_BUILD_TYPE=Release"
    end

    # Turn autowiring off if building without boost
    args << "-DAUTOWIRING_BUILD_AUTONET=OFF" if build.without? "boost"

    # Check if we want a pre-C++11 build
    args << "-DUSE_LIBCXX=OFF" if build.without? "libcxx"

    system "cmake", ".", *args
    system "make -j 8 || make"
    system "make install"
  end

  test do
    # Check if cmake can find installed autowiring
    (testpath/"CMakeLists.txt").write("find_package(autowiring)")
    system "cmake", "."
  end
end
