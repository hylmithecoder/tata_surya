#import <Cocoa/Cocoa.h>
#include <objc/NSObject.h>
#include <string>
using namespace std;

bool showConfirmAlert(string message) {
  NSAlert *alert = [[NSAlert alloc] init];
  string setMessage = "Nama Mu Adalah " + message;
  [alert setMessageText:[NSString stringWithUTF8String:setMessage.c_str()]];

  [alert addButtonWithTitle:@"Yes"];
  [alert addButtonWithTitle:@"No"];

  NSModalResponse response = [alert runModal];
  return response == NSAlertFirstButtonReturn;
}

string showAlertAndGetInput(std::string message, std::string placeholder) {
  // 1. Create the Alert
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setMessageText:@"Silahkan Masukkan Nama Anda"];
  [alert setInformativeText:[NSString stringWithUTF8String:message.c_str()]];
  [alert addButtonWithTitle:@"OK"];
  [alert addButtonWithTitle:@"Cancel"];

  // 2. Create the Text Field for Input
  NSTextField *input =
      [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
  [input
      setPlaceholderString:[NSString stringWithUTF8String:placeholder.c_str()]];
  [alert setAccessoryView:input];

  // 3. Display the alert and handle results
  NSInteger button = [alert runModal];
  if (button == NSAlertFirstButtonReturn) {
    // "OK" clicked
    [input validateEditing];
    showConfirmAlert([[input stringValue] UTF8String]);
    return [[input stringValue] UTF8String];
  }

  return ""; // Cancelled
}
