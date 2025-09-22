class Oscar < Formula
  desc "Open Source CPAP Analysis Reporter (OSCAR)"
  homepage "https://www.sleepfiles.com/OSCAR/"
  license "GPL-3.0-or-later"

  url "https://gitlab.com/CrimsonNape/OSCAR-code.git",
      using:  :git,
      tag:    "v1.6.1"
  head "https://gitlab.com/CrimsonNape/OSCAR-code.git", using: :git

  depends_on "qt@5"
  depends_on "pkg-config" => :build
  uses_from_macos "zlib"

  on_linux do
    depends_on "gcc" => :build   # гарантируем наличие компилятора в Homebrew
  end

  def install
    # qmake парсит вывод компилятора; принудим англоязычную локаль
    ENV["LC_ALL"] = "C"
    ENV["LANG"]   = "C"

    # Определим, что использовать как CC/CXX
    qmake_cc  = ENV.cc
    qmake_cxx = ENV.cxx

    if OS.linux?
      # Используем именно brewed gcc, чтобы не зависеть от системы
      gcc_formula = Formula["gcc"]
      gcc_major   = gcc_formula.version.major
      qmake_cc    = (gcc_formula.opt_bin/"gcc-#{gcc_major}").to_s
      qmake_cxx   = (gcc_formula.opt_bin/"g++-#{gcc_major}").to_s
    end

    mkdir "build" do
      system Formula["qt@5"].opt_bin/"qmake",
             "-spec", "linux-g++",
             "QMAKE_CC=#{qmake_cc}",
             "QMAKE_CXX=#{qmake_cxx}",
             "QMAKE_LINK=#{qmake_cxx}",
             "QMAKE_LRELEASE=#{Formula["qt@5"].opt_bin}/lrelease",
             "CONFIG+=release",
             "PREFIX=#{prefix}",
             "../OSCAR_QT.pro"

      system "make", "-j#{ENV.make_jobs}"

      # У проекта нет цели install — ставим бинарник вручную
      bin.install "oscar/OSCAR"
      doc.install Dir["docs/*"], "README" if (buildpath/"docs").exist?
    end
  end

  test do
    assert_predicate bin/"OSCAR", :exist?
    output = shell_output("#{bin}/OSCAR --version 2>&1", 1)
    assert_match(/OSCAR/i, output)
  end
end
