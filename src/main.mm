#include "Windowing.mm"

int main(int argc, const char *argv[]) {
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
