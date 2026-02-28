#include "../include/BaseWindow.hpp"
#include "AlertDialog.mm"
#include "Windowing.mm"

int main(int argc, const char *argv[]) {
  // string name = showAlertAndGetInput("Masukkan Nama Anda", "Nama");
  // cout << "Nama Anda: " << name << endl;

  // Create the application instance
  NSApplication *app = [NSApplication sharedApplication];

  // Create the delegate
  AppDelegate *delegate = [[AppDelegate alloc] init];
  [app setDelegate:delegate];

  // Set the activation policy (needed for standalone executable to show in
  // dock/menu)
  [app setActivationPolicy:NSApplicationActivationPolicyRegular];

  // Run the application
  [app run];

  return 0;
}
