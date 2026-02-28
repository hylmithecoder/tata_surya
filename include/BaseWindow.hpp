#pragma once

#include <algorithm>
#include <functional>
#include <map>
#include <string>
#include <vector>

using namespace std;
// Forward declaration of the Objective-C internal state to hide NSWindow from
// C++
namespace Utils {
struct WindowState;

// Format string ala printf ("%d", "%s", dll)
template <typename... Args> std::string format(const char *fmt, Args... args) {
  char buffer[1024];
  snprintf(buffer, sizeof(buffer), fmt, args...);
  return std::string(buffer);
}

class BaseWindow {
public:
  // Lifecycle
  BaseWindow(int width, int height, const std::string &title);
  ~BaseWindow();

  void show();
  void endShow();
  void center();

  // UI Builder Methods
  void setLabelAlignment(const string &align); // "left", "center", "right"
  void addLabel(const string &text, int fontSize = 14,
                const string &colorHex = "");
  void addSeparator(); // Visual horizontal line separator
  void addInput(const string &id, const string &placeholder, int width = 200,
                int height = 24);
  void
  addInputRow(const string &label, const string &id,
              const string &placeholder = ""); // Label + Input on same line
  void addButton(const string &title, int width = 0, int height = 28,
                 std::function<void()> onClick = nullptr);
  void addSpacer(int height = 8); // Empty vertical space

  // Docking: snap window to screen edge
  // Positions: "left", "right", "top", "bottom",
  //            "top-left", "top-right", "bottom-left", "bottom-right"
  void dock(const string &position);

  // Auto-tile all open BaseWindows in a grid
  static void tileWindows();

  // This sets up a basic empty table with a default single column for now.
  void addTable(int width, int height);

  // Fetch values from UI elements
  string getInputValue(const string &id) const;

private:
  WindowState *state; // Opaque pointer to hide Objective-C details
  static std::vector<BaseWindow *> allWindows; // Track all open windows
};
} // namespace Utils
