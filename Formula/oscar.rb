class Oscar < Formula
  desc "Open Source CPAP Analysis Reporter"
  homepage "https://gitlab.com/CrimsonNape/OSCAR-code"
  url "https://gitlab.com/CrimsonNape/OSCAR-code/-/archive/v1.6.1/OSCAR-code-v1.6.1.tar.gz"
  sha256 "0282f4e8347c3e52911be1809eae8832da64e961cae9c968278a0a6fbceb5d51"
  license "GPL-3.0-or-later"
  head "https://gitlab.com/CrimsonNape/OSCAR-code.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "qt@5"
  depends_on "libzip"
  depends_on "zlib"

def install
  # убедимся, что qmake виден
  ENV.prepend_path "PATH", Formula["qt@5"].opt_bin

  # Генерим Makefile и собираем
  system "qmake", "-config", "release"
  system "make"

  bin.install "OSCAR"

  (share/"oscar").install Dir["icons/*"] rescue nil
end


  test do
    system "#{bin}/OSCAR", "--version"
  end
end
