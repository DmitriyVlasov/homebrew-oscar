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
    depends_on "llvm" => :build  # используем clang/clang++ из Homebrew
    # При желании можно добавить: depends_on "make" => :build
  end

  def install
    # qmake парсит вывод компилятора — фиксируем англоязычную локаль
    ENV["LC_ALL"] = "C"
    ENV["LANG"]   = "C"

    # Выбираем компилятор: на Linux — clang++ из Homebrew LLVM
    cxx = if OS.linux?
      Formula["llvm"].opt_bin/"clang++"
    else
      ENV.cxx
    end

    mkdir "build" do
      # Сборка через qmake (Qt5). Проект в корне называется OSCAR_QT.pro
      system Formula["qt@5"].opt_bin/"qmake",
             # профиль для clang на Linux
             "-spec", "linux-clang",
             # Явно укажем инструменты и потоки
             "QMAKE_CXX=#{cxx}",
             "QMAKE_LINK=#{cxx}",
             "QMAKE_CXXFLAGS+=-pthread",
             "QMAKE_LFLAGS+=-pthread",
             # lrelease из qt@5 (для перевода строк, если понадобится)
             "QMAKE_LRELEASE=#{Formula["qt@5"].opt_bin}/lrelease",
             # Релизная сборка
             "CONFIG+=release thread",
             # Префикс (не используется install-целью, но на будущее)
             "PREFIX=#{prefix}",
             # сам проект
             "../OSCAR_QT.pro"

      system "make", "-j#{ENV.make_jobs}"

      # У проекта нет цели "make install": ставим бинарник вручную
      bin.install "oscar/OSCAR"

      # Документацию положим, если есть
      doc.install Dir["docs/*"], "README" if (buildpath/"docs").exist?

      # При желании можно добавить desktop-файл/иконку, если появятся в репо:
      # (share/"applications").install "resources/oscar.desktop" if File.exist?("resources/oscar.desktop")
      # (share/"icons/hicolor/256x256/apps").install "resources/icons/oscar.png" if File.exist?("resources/icons/oscar.png")
    end
  end

  test do
    assert_predicate bin/"OSCAR", :exist?
    # В GUI-приложениях код возврата может быть !=0; проверим хотя бы вывод
    output = shell_output("#{bin}/OSCAR --version 2>&1", 1)
    assert_match(/OSCAR/i, output)
  end
end
