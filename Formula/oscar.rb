class Oscar < Formula
  desc "Open Source CPAP Analysis Reporter"
  homepage "https://gitlab.com/CrimsonNape/OSCAR-code"
  url "https://gitlab.com/CrimsonNape/OSCAR-code/-/archive/v1.6.1/OSCAR-code-v1.6.1.tar.gz"
  sha256 "0282f4e8347c3e52911be1809eae8832da64e961cae9c968278a0a6fbceb5d51"
  license "GPL-3.0-or-later"
  head "https://gitlab.com/CrimsonNape/OSCAR-code.git", branch: "master"

  # Qt5 включает qmake, qcollectiongenerator, lrelease и т.п.
  depends_on "qt@5"
  uses_from_macos "zlib"

  # oscar.pro на Linux явно линкует -lX11 и -lGLU
  on_linux do
    depends_on "libx11"
    depends_on "glu"
  end

  livecheck do
    url :stable
    strategy :git
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  def install
    # гарантируем qmake из qt@5
    ENV.prepend_path "PATH", Formula["qt@5"].opt_bin

    # корневой qmake-проект (subdirs) -> соберёт подкаталог oscar/
    system "qmake", "OSCAR_QT.pro", "CONFIG+=release"
    system "make", "-j#{ENV.make_jobs}"

    # итоговый бинарник лежит в подкаталоге oscar/
    bin.install "oscar/OSCAR"

    # опционально: можно установить сгенерированные справку/переводы,
    # но приложение умеет работать и с вшитыми ресурсами.
    # (pkgshare/"oscar").install Dir["oscar/Help/*", "oscar/Html/*", "oscar/Translations/*"] rescue nil
  end

  test do
    # help отдаёт текст и не запускает GUI
    assert_match "Usage", shell_output("#{bin}/OSCAR --help 2>&1")
  end
end
