class Oscar < Formula
  desc "Open Source CPAP Analysis Reporter"
  homepage "https://gitlab.com/CrimsonNape/OSCAR-code"
  url "https://gitlab.com/CrimsonNape/OSCAR-code/-/archive/v1.6.1/OSCAR-code-v1.6.1.tar.gz"
  sha256 "deadbeef"
  license "GPL-3.0-or-later"
  head "https://gitlab.com/CrimsonNape/OSCAR-code.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "qt@5"
  depends_on "libzip"
  depends_on "zlib"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    system "#{bin}/OSCAR", "--version"
  end
end
