class Oscar < Formula
  desc "Open Source CPAP Analysis Reporter"
  homepage "https://gitlab.com/CrimsonNape/OSCAR-code"
  url "https://gitlab.com/CrimsonNape/OSCAR-code/-/archive/v1.6.1/OSCAR-code-v1.6.1.tar.gz"
  sha256 "0282f4e8347c3e52911be1809eae8832da64e961cae9c968278a0a6fbceb5d51"
  license "GPL-3.0-or-later"
  head "https://gitlab.com/CrimsonNape/OSCAR-code.git", branch: "master"

  depends_on "qt@5"
  uses_from_macos "zlib"

  on_linux do
    depends_on "libx11"
    depends_on "mesa-glu"
    depends_on "pkg-config" => :build
  end

  livecheck do
    url :stable
    strategy :git
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  def install
    # гарантируем qmake из qt@5
    ENV.prepend_path "PATH", Formula["qt@5"].opt_bin

    # корневой qmake-проект (subdirs) собирает подкаталог oscar/
    system "qmake", "OSCAR_QT.pro", "CONFIG+=release"
    system "make", "-j#{ENV.make_jobs}"

    # бинарник может оказаться в oscar/OSCAR или oscar/release/OSCAR
    exe = if File.exist?("oscar/OSCAR")
      "oscar/OSCAR"
    elsif File.exist?("oscar/release/OSCAR")
      "oscar/release/OSCAR"
    else
      # запасной вариант — вдруг проект изменит структуру
      "OSCAR"
    end

    bin.install exe

    # ресурсы не обязательны для запуска; при желании можно раскомментировать:
    # (pkgshare/"oscar").install Dir["oscar/Help/*", "oscar/Html/*", "oscar/Translations/*"] rescue nil
  end

  test do
    assert_match "Usage", shell_output("#{bin}/OSCAR --help 2>&1")
  end
end
