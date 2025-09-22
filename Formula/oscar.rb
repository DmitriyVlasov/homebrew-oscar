class Oscar < Formula
  desc "Open Source CPAP Analysis Reporter"
  homepage "https://gitlab.com/CrimsonNape/OSCAR-code"
  url "https://gitlab.com/CrimsonNape/OSCAR-code/-/archive/v1.6.1/OSCAR-code-v1.6.1.tar.gz"
  sha256 "0282f4e8347c3e52911be1809eae8832da64e961cae9c968278a0a6fbceb5d51"
  license "GPL-3.0-or-later"
  head "https://gitlab.com/CrimsonNape/OSCAR-code.git", branch: "master"

  # qmake/Qt5 нужны и на сборку, и на рантайм
  depends_on "qt@5"
  depends_on "libzip"
  depends_on "zlib"

  # (опционально) удобно для обновлений
  livecheck do
    url :stable
    strategy :git
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  def install
    # убедимся, что берем qmake из qt@5, а не системный
    ENV.prepend_path "PATH", Formula["qt@5"].opt_bin

    # генерим Makefile и собираем
    system "qmake", "-config", "release"
    system "make", "-j#{ENV.make_jobs}"

    # ставим бинарь
    bin.install "OSCAR"

    # иконки — по желанию, если проект их ищет по относительным путям
    (share/"oscar").install Dir["icons/*"] rescue nil
  end

  test do
    # Проверим, что бинарь вообще запускается и выводит help
    assert_match "Usage", shell_output("#{bin}/OSCAR --help 2>&1")
  end
end
