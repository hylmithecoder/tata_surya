#include "../include/BaseWindow.hpp"
#import <Cocoa/Cocoa.h>

// Define a simple Objective-C class to handle button clicks and route them to
// our std::function
@interface ButtonActionHandler : NSObject
@property(nonatomic, assign) std::function<void()> action;
- (void)onButtonClicked:(id)sender;
@end

@implementation ButtonActionHandler
- (void)onButtonClicked:(id)sender {
  if (self.action) {
    self.action();
  }
}
@end

// Flipped so coordinate system starts from Top-Left (like ImGui/Web)
@interface FlippedClipView : NSClipView
@end

@implementation FlippedClipView
- (BOOL)isFlipped {
  return YES;
}
@end

// The internal state holding Cocoa specific objects
namespace Utils {
struct WindowState {
  NSWindow *window;
  NSStackView *stackView;
  NSScrollView *scrollContainer;
  std::map<std::string, NSTextField *> textFields;
  NSMutableArray<ButtonActionHandler *> *buttonHandlers;

  NSTextAlignment currentAlignment;

  WindowState() : currentAlignment(NSTextAlignmentLeft) {
    buttonHandlers = [[NSMutableArray alloc] init];
  }

  ~WindowState() {}
};

// Static member initialization
std::vector<BaseWindow *> BaseWindow::allWindows;

BaseWindow::BaseWindow(int width, int height, const std::string &title) {
  state = new WindowState();
  allWindows.push_back(this); // Track this window

  NSRect frame = NSMakeRect(0, 0, width, height);
  NSWindowStyleMask style =
      NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
      NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable;

  state->window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:style
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];

  state->currentAlignment = NSTextAlignmentLeft;

  [state->window setTitle:[NSString stringWithUTF8String:title.c_str()]];
  [state->window center];

  // Dark background like ImGui
  [state->window setBackgroundColor:[NSColor colorWithRed:0.13
                                                    green:0.13
                                                     blue:0.16
                                                    alpha:1.0]];

  // Create the stack view for auto-layout
  state->stackView = [[NSStackView alloc] init];
  [state->stackView setTranslatesAutoresizingMaskIntoConstraints:NO];
  [state->stackView setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [state->stackView setAlignment:NSLayoutAttributeWidth]; // Fill width
  [state->stackView setSpacing:6.0];
  [state->stackView setEdgeInsets:NSEdgeInsetsMake(12.0, 14.0, 12.0, 14.0)];
  [state->stackView setDistribution:NSStackViewDistributionFill];

  // Prevent clipping
  [state->stackView
      setClippingResistancePriority:NSLayoutPriorityRequired
                     forOrientation:NSLayoutConstraintOrientationVertical];
  [state->stackView setHuggingPriority:NSLayoutPriorityRequired
                        forOrientation:NSLayoutConstraintOrientationVertical];

  // Create scroll view with flipped clip view for Top-to-Bottom flow
  state->scrollContainer = [[NSScrollView alloc] init];
  [state->scrollContainer setHasVerticalScroller:YES];
  [state->scrollContainer setAutohidesScrollers:YES];
  [state->scrollContainer setDrawsBackground:NO];
  [state->scrollContainer
      setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

  // Replace default clip view with flipped one
  FlippedClipView *flippedClip =
      [[FlippedClipView alloc] initWithFrame:[state->scrollContainer bounds]];
  [state->scrollContainer setContentView:flippedClip];

  [state->scrollContainer setDocumentView:state->stackView];

  // Pin stack view edges to scroll view clip view
  [state->stackView.topAnchor constraintEqualToAnchor:flippedClip.topAnchor]
      .active = YES;
  [state->stackView.leadingAnchor
      constraintEqualToAnchor:flippedClip.leadingAnchor]
      .active = YES;
  [state->stackView.trailingAnchor
      constraintEqualToAnchor:flippedClip.trailingAnchor]
      .active = YES;

  state->window.contentView = state->scrollContainer;
}

BaseWindow::~BaseWindow() {
  // Remove from tracked windows
  allWindows.erase(std::remove(allWindows.begin(), allWindows.end(), this),
                   allWindows.end());
  if (state) {
    delete state;
  }
}

void BaseWindow::show() {
  [state->window makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
}

void BaseWindow::endShow() { [state->window close]; }

void BaseWindow::center() { [state->window center]; }

void BaseWindow::setLabelAlignment(const std::string &align) {
  if (align == "center")
    state->currentAlignment = NSTextAlignmentCenter;
  else if (align == "right")
    state->currentAlignment = NSTextAlignmentRight;
  else
    state->currentAlignment = NSTextAlignmentLeft;
}

void BaseWindow::addLabel(const std::string &text, int fontSize,
                          const std::string &colorHex) {

  NSTextField *label = [NSTextField
      wrappingLabelWithString:[NSString stringWithUTF8String:text.c_str()]];
  [label setEditable:NO];
  [label setSelectable:NO];
  [label setBordered:NO];
  [label setDrawsBackground:NO];
  [label setFont:[NSFont fontWithName:@"Menlo" size:fontSize]];
  if (label.font == nil) {
    [label setFont:[NSFont monospacedSystemFontOfSize:fontSize
                                               weight:NSFontWeightRegular]];
  }
  [label setAlignment:state->currentAlignment];

  // Prevent compression
  [label setContentCompressionResistancePriority:NSLayoutPriorityRequired
                                  forOrientation:
                                      NSLayoutConstraintOrientationVertical];
  [label setContentHuggingPriority:NSLayoutPriorityDefaultLow
                    forOrientation:NSLayoutConstraintOrientationHorizontal];

  // Colors
  if (!colorHex.empty()) {
    if (colorHex == "red")
      [label setTextColor:[NSColor colorWithRed:1.0
                                          green:0.3
                                           blue:0.3
                                          alpha:1.0]];
    else if (colorHex == "blue")
      [label setTextColor:[NSColor colorWithRed:0.4
                                          green:0.65
                                           blue:1.0
                                          alpha:1.0]];
    else if (colorHex == "green")
      [label setTextColor:[NSColor colorWithRed:0.4
                                          green:0.9
                                           blue:0.4
                                          alpha:1.0]];
    else if (colorHex == "yellow")
      [label setTextColor:[NSColor colorWithRed:1.0
                                          green:0.85
                                           blue:0.3
                                          alpha:1.0]];
    else if (colorHex == "white")
      [label setTextColor:[NSColor colorWithWhite:0.92 alpha:1.0]];
    else if (colorHex == "black")
      [label setTextColor:[NSColor blackColor]];
  } else {
    [label setTextColor:[NSColor colorWithWhite:0.88 alpha:1.0]];
  }

  [state->stackView addArrangedSubview:label];
}

void BaseWindow::addSeparator() {
  NSBox *separator = [[NSBox alloc] init];
  [separator setBoxType:NSBoxSeparator];
  [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
  [separator.heightAnchor constraintEqualToConstant:1].active = YES;
  [state->stackView addArrangedSubview:separator];
}

void BaseWindow::addSpacer(int height) {
  NSView *spacer = [[NSView alloc] init];
  [spacer setTranslatesAutoresizingMaskIntoConstraints:NO];
  [spacer.heightAnchor constraintEqualToConstant:height].active = YES;
  [state->stackView addArrangedSubview:spacer];
}

void BaseWindow::addInput(const std::string &id, const std::string &placeholder,
                          int width, int height) {
  NSTextField *input = [[NSTextField alloc] init];
  [input setTranslatesAutoresizingMaskIntoConstraints:NO];
  [input
      setPlaceholderString:[NSString stringWithUTF8String:placeholder.c_str()]];

  // Style the input for dark theme
  [input setDrawsBackground:YES];
  [input setBackgroundColor:[NSColor colorWithRed:0.18
                                            green:0.18
                                             blue:0.22
                                            alpha:1.0]];
  [input setTextColor:[NSColor colorWithWhite:0.92 alpha:1.0]];
  [input setBordered:YES];
  [input setBezelStyle:NSTextFieldSquareBezel];
  [input setFont:[NSFont fontWithName:@"Menlo" size:12]];
  if (input.font == nil) {
    [input setFont:[NSFont monospacedSystemFontOfSize:12
                                               weight:NSFontWeightRegular]];
  }

  [input.heightAnchor constraintEqualToConstant:height].active = YES;

  [state->stackView addArrangedSubview:input];

  // Store for later retrieval
  state->textFields[id] = input;
}

void BaseWindow::addInputRow(const std::string &labelText,
                             const std::string &id,
                             const std::string &placeholder) {
  // Create horizontal stack for label + input
  NSStackView *row = [[NSStackView alloc] init];
  [row setTranslatesAutoresizingMaskIntoConstraints:NO];
  [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [row setSpacing:8.0];
  [row setAlignment:NSLayoutAttributeCenterY];
  [row setDistribution:NSStackViewDistributionFill];

  // Label part (fixed width)
  NSTextField *label = [NSTextField
      labelWithString:[NSString stringWithUTF8String:labelText.c_str()]];
  [label setTranslatesAutoresizingMaskIntoConstraints:NO];
  [label setFont:[NSFont fontWithName:@"Menlo" size:12]];
  if (label.font == nil) {
    [label setFont:[NSFont monospacedSystemFontOfSize:12
                                               weight:NSFontWeightRegular]];
  }
  [label setTextColor:[NSColor colorWithWhite:0.75 alpha:1.0]];
  [label setAlignment:NSTextAlignmentRight];
  [label.widthAnchor constraintEqualToConstant:40].active = YES;
  [label setContentHuggingPriority:NSLayoutPriorityRequired
                    forOrientation:NSLayoutConstraintOrientationHorizontal];

  // Input part (fills remaining space)
  NSTextField *input = [[NSTextField alloc] init];
  [input setTranslatesAutoresizingMaskIntoConstraints:NO];
  [input
      setPlaceholderString:[NSString stringWithUTF8String:placeholder.c_str()]];
  [input setDrawsBackground:YES];
  [input setBackgroundColor:[NSColor colorWithRed:0.18
                                            green:0.18
                                             blue:0.22
                                            alpha:1.0]];
  [input setTextColor:[NSColor colorWithWhite:0.92 alpha:1.0]];
  [input setBordered:YES];
  [input setBezelStyle:NSTextFieldSquareBezel];
  [input setFont:[NSFont fontWithName:@"Menlo" size:12]];
  if (input.font == nil) {
    [input setFont:[NSFont monospacedSystemFontOfSize:12
                                               weight:NSFontWeightRegular]];
  }
  [input.heightAnchor constraintEqualToConstant:24].active = YES;
  [input setContentHuggingPriority:NSLayoutPriorityDefaultLow
                    forOrientation:NSLayoutConstraintOrientationHorizontal];

  [row addArrangedSubview:label];
  [row addArrangedSubview:input];

  [state->stackView addArrangedSubview:row];

  state->textFields[id] = input;
}

void BaseWindow::addButton(const std::string &title, int width, int height,
                           std::function<void()> onClick) {
  NSButton *button = [[NSButton alloc] init];
  [button setTranslatesAutoresizingMaskIntoConstraints:NO];
  [button setTitle:[NSString stringWithUTF8String:title.c_str()]];
  [button setBezelStyle:NSBezelStyleRounded];
  [button setFont:[NSFont fontWithName:@"Menlo" size:12]];
  if (button.font == nil) {
    [button setFont:[NSFont monospacedSystemFontOfSize:12
                                                weight:NSFontWeightMedium]];
  }

  ButtonActionHandler *handler = [[ButtonActionHandler alloc] init];
  handler.action = onClick;
  [state->buttonHandlers addObject:handler];

  [button setTarget:handler];
  [button setAction:@selector(onButtonClicked:)];

  [button.heightAnchor constraintEqualToConstant:height].active = YES;
  if (width > 0) {
    [button.widthAnchor constraintEqualToConstant:width].active = YES;
  }
  // If width is 0, it stretches to fill the stack view width automatically

  [state->stackView addArrangedSubview:button];
}

void BaseWindow::addTable(int width, int height) {
  // Build a basic Scroll/Table view
  NSScrollView *scrollView =
      [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, width, height)];

  [scrollView setHasVerticalScroller:YES];
  [scrollView setHasHorizontalScroller:YES];
  [scrollView setAutohidesScrollers:YES];

  NSTableView *tableView =
      [[NSTableView alloc] initWithFrame:[scrollView bounds]];

  // Add a single column for demonstration.
  NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"Column1"];
  [[column headerCell] setStringValue:@"Data"];
  [column setWidth:width];
  [tableView addTableColumn:column];

  [scrollView setDocumentView:tableView];

  [state->stackView addArrangedSubview:scrollView];

  [scrollView.widthAnchor constraintEqualToConstant:width].active = YES;
  [scrollView.heightAnchor constraintEqualToConstant:height].active = YES;
}

std::string BaseWindow::getInputValue(const std::string &id) const {
  auto it = state->textFields.find(id);
  if (it != state->textFields.end()) {
    NSTextField *input = it->second;
    return [[input stringValue] UTF8String];
  }
  return "";
}

void BaseWindow::dock(const std::string &position) {
  NSScreen *screen = [NSScreen mainScreen];
  NSRect screenFrame = [screen visibleFrame];
  CGFloat sw = screenFrame.size.width;
  CGFloat sh = screenFrame.size.height;
  CGFloat sx = screenFrame.origin.x;
  CGFloat sy = screenFrame.origin.y;

  NSRect newFrame;

  if (position == "left") {
    newFrame = NSMakeRect(sx, sy, sw / 2, sh);
  } else if (position == "right") {
    newFrame = NSMakeRect(sx + sw / 2, sy, sw / 2, sh);
  } else if (position == "top") {
    newFrame = NSMakeRect(sx, sy + sh / 2, sw, sh / 2);
  } else if (position == "bottom") {
    newFrame = NSMakeRect(sx, sy, sw, sh / 2);
  } else if (position == "top-left") {
    newFrame = NSMakeRect(sx, sy + sh / 2, sw / 2, sh / 2);
  } else if (position == "top-right") {
    newFrame = NSMakeRect(sx + sw / 2, sy + sh / 2, sw / 2, sh / 2);
  } else if (position == "bottom-left") {
    newFrame = NSMakeRect(sx, sy, sw / 2, sh / 2);
  } else if (position == "bottom-right") {
    newFrame = NSMakeRect(sx + sw / 2, sy, sw / 2, sh / 2);
  } else if (position == "full") {
    newFrame = screenFrame;
  } else {
    // Default: center
    [state->window center];
    return;
  }

  [state->window setFrame:newFrame display:YES animate:YES];
}

void BaseWindow::tileWindows() {
  if (allWindows.empty())
    return;

  NSScreen *screen = [NSScreen mainScreen];
  NSRect screenFrame = [screen visibleFrame];
  CGFloat sw = screenFrame.size.width;
  CGFloat sh = screenFrame.size.height;
  CGFloat sx = screenFrame.origin.x;
  CGFloat sy = screenFrame.origin.y;

  int count = (int)allWindows.size();

  // Calculate grid dimensions
  int cols = 1;
  int rows = 1;
  if (count == 1) {
    cols = 1;
    rows = 1;
  } else if (count == 2) {
    cols = 2;
    rows = 1;
  } else if (count <= 4) {
    cols = 2;
    rows = 2;
  } else if (count <= 6) {
    cols = 3;
    rows = 2;
  } else if (count <= 9) {
    cols = 3;
    rows = 3;
  } else {
    cols = 4;
    rows = (count + 3) / 4;
  }

  CGFloat cellW = sw / cols;
  CGFloat cellH = sh / rows;

  for (int i = 0; i < count; i++) {
    int col = i % cols;
    int row = i / cols;
    // macOS origin is bottom-left, so row 0 = top
    CGFloat x = sx + col * cellW;
    CGFloat y = sy + sh - (row + 1) * cellH;
    NSRect frame = NSMakeRect(x, y, cellW, cellH);
    [allWindows[i]->state->window setFrame:frame display:YES animate:YES];
  }
}

} // namespace Utils