require "formula"

class Autowiring < Formula
  homepage "http://autowiring.io/"
  url "https://github.com/leapmotion/autowiring/archive/v0.7.6.tar.gz"
  sha1 "e23c1f4ec29469196541f71a2a3890fa3a56067d"

  depends_on "cmake" => :build

  def install
    # Command line args to pass to CMake
    args = [
      "-DCMAKE_INSTALL_PREFIX=#{prefix}"
    ]

    # Turn autowiring off if building without boost
    args << "-DAUTOWIRING_BUILD_AUTONET=OFF" if build.without? "boost"

    # Build Debug
    system "cmake", ".", "-DCMAKE_BUILD_TYPE=Debug", *args
    system "make -j || make"
    system "make install"

    # Build release
    system "cmake", ".", "-DCMAKE_BUILD_TYPE=Release"
    system "make -j || make"
    system "make install"

    # Link CMake config for autowiring
    (share/'autowiring').install prefix/'cmake'
    (share/'autowiring').install prefix/'lib'
    (share/'autowiring').install prefix/'include'
  end

  test do
    # Check if cmake can find installed autowiring
    (testpath/"CMakeLists.txt").write("find_package(autowiring)")
    system "cmake", "."
  end
end
