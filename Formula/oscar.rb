# Формула для личного tap’а: например, putchastick/oscar/oscar.rb
class Oscar < Formula
  desc "Open Source CPAP Analysis Reporter (OSCAR)"
  homepage "https://www.sleepfiles.com/OSCAR/"
  license "GPL-3.0-or-later"

  # Стабильная сборка из официального репозитория разработчиков (GitLab)
  url "https://gitlab.com/CrimsonNape/OSCAR-code.git",
      using:  :git,
      tag:    "v1.6.1"   # актуальная линия 1.6.x
  head "https://gitlab.com/CrimsonNape/OSCAR-code.git", using: :git

  # Qt5 требуется согласно пакетам Debian/FreeBSD для 1.5–1.6.x ветки
  depends_on "qt@5"
  depends_on "pkg-config" => :build

  # zlib тянется из macOS; под Linux Homebrew подтянет свой пакет
  uses_from_macos "zlib"

  def install
    # Собираем в отдельном каталоге
    mkdir "build" do
      # Явно используем qmake из qt@5, чтобы избежать коллизий с системным qmake
      system Formula["qt@5"].opt_bin/"qmake", "../OSCAR_QT.pro",
             "CONFIG+=release",
             "PREFIX=#{prefix}"

      # Сборка и установка
      system "make"
      system "make", "install"
    end

    # На всякий случай: если upstream не устанавливает desktop-файл/иконки сам,
    # можно раскомментировать и подстроить пути (оставляю как подсказку).
    # (share/"applications").install "resources/oscar.desktop" if File.exist?("resources/oscar.desktop")
    # (share/"icons/hicolor/256x256/apps").install "resources/icons/oscar.png" if File.exist?("resources/icons/oscar.png")
  end

  test do
    # GUI мы не запускаем; проверяем, что бинарник установился
    assert_predicate bin/"OSCAR", :exist?, "OSCAR binary must exist"
    # Иногда приложение печатает помощь/версию; не критично, если код возврата != 0
    out = shell_output("#{bin}/OSCAR --version 2>&1", 1)
    assert_match(/OSCAR/i, out)
  end
end
