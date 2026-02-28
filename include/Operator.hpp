#include "BaseWindow.hpp"
#include <AppKit/AppKit.h>
#include <string>
using namespace std;

namespace Tugas {
class Operator {
public:
  Operator() {
    soal1();
    soal2();
    soal3();
    soal4();
    soal5();
    // Auto-tile all windows into a grid
    Utils::BaseWindow::tileWindows();
  }

  ~Operator();

  void soal1();
  void soal2();
  void soal3();
  void soal4();
  void soal5();
};
} // namespace Tugas