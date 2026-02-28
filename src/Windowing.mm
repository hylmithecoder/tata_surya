#include "../include/BaseWindow.hpp"
#include "../include/Operator.hpp"
#import <Cocoa/Cocoa.h>
#include <cmath>
#include <iostream>
#include <vector>

using namespace Tugas;
using namespace std;

// --- C++ Domain Layer (Namespaces & Physics) ---
namespace SolarPhysics {

struct Vector2 {
  double x, y;
  Vector2(double x = 0, double y = 0) : x(x), y(y) {}

  Vector2 operator+(const Vector2 &other) const {
    return Vector2(x + other.x, y + other.y);
  }
  Vector2 operator-(const Vector2 &other) const {
    return Vector2(x - other.x, y - other.y);
  }
  Vector2 operator*(double scalar) const {
    return Vector2(x * scalar, y * scalar);
  }

  double length() const { return sqrt(x * x + y * y); }
  Vector2 normalized() const {
    double len = length();
    return (len > 0) ? Vector2(x / len, y / len) : Vector2(0, 0);
  }
};

class CelestialBody {
public:
  Vector2 position;
  Vector2 velocity;
  double mass;
  double radius;
  float r, g, b; // Color

  CelestialBody(Vector2 pos, Vector2 vel, double mass, double radius, float r,
                float g, float b)
      : position(pos), velocity(vel), mass(mass), radius(radius), r(r), g(g),
        b(b) {}

  void applyGravity(const CelestialBody &other, double G) {
    Vector2 direction = other.position - position;
    double distance = direction.length();
    if (distance < radius + other.radius)
      return; // Simple collision avoidance (ignore)

    double forceMagnitude = (G * mass * other.mass) / (distance * distance);
    Vector2 force = direction.normalized() * forceMagnitude;

    // F = ma -> a = F/m
    Vector2 acceleration = force * (1.0 / mass);
    velocity =
        velocity +
        acceleration; // Simplify: apply accel to velocity directly per step
  }

  void update(double dt) { position = position + velocity * dt; }
};
} // namespace SolarPhysics

// --- Objective-C View Layer ---

@interface WindowingAndCocoa : NSObject {
}
@end

@implementation WindowingAndCocoa

- (void)showInfo:(NSString *)msg {
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = @"Info";
  alert.informativeText = msg;
  [alert runModal];
}

- (BOOL)showConfirmAlert:(NSString *)message
             withChoice1:(NSString *)choice1
             withChoice2:(NSString *)choice2 {
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = @"Konfirmasi";
  alert.informativeText = message;

  [alert addButtonWithTitle:choice1];
  [alert addButtonWithTitle:choice2];

  NSModalResponse response = [alert runModal];
  return response == NSAlertFirstButtonReturn;
}

@end

@interface SolarSystemView : NSView {
  vector<SolarPhysics::CelestialBody> bodies;
  NSTimer *animationTimer;
  WindowingAndCocoa *windowingAndCocoa;
}
@end

@implementation SolarSystemView

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    // Initialize Physics Simulation
    // 1. The Sun (Static, Heavy, Yellow)
    bodies.emplace_back(
        SolarPhysics::Vector2(0, 0), // Center (relative to view center)
        SolarPhysics::Vector2(0, 0), // Static
        10000.0,                     // Mass
        30.0,                        // Radius
        1.0f, 1.0f, 0.0f             // Yellow
    );

    // 2. Earth-like Planet (Orbiting, Blue)
    // Velocity for circular orbit: v = sqrt(G * M / r)
    // Let's assume G=1.0 for simplicity in this visual sim
    double r = 150.0;
    double v = sqrt(1.0 * 10000.0 / r);

    bodies.emplace_back(SolarPhysics::Vector2(r, 0), // Start at right
                        SolarPhysics::Vector2(0, v), // Velocity up
                        100.0,                       // Mass
                        10.0,                        // Radius
                        0.0f, 0.5f, 1.0f             // Blue
    );

    // 3. Mars-like Planet (Orbiting, Red)
    double r2 = 220.0;
    double v2 = sqrt(1.0 * 10000.0 / r2);

    bodies.emplace_back(SolarPhysics::Vector2(0, -r2), // Start at bottom
                        SolarPhysics::Vector2(v2, 0),  // Velocity right
                        80.0,                          // Mass
                        8.0,                           // Radius
                        1.0f, 0.2f, 0.0f               // Red
    );

    // Start Animation Loop (60 FPS)
    double fps = 60;
    animationTimer =
        [NSTimer scheduledTimerWithTimeInterval:1.0 / fps
                                         target:self
                                       selector:@selector(updatePhysics)
                                       userInfo:nil
                                        repeats:YES];
  }
  return self;
}

- (void)updatePhysics {
  double G = 1.0;
  double dt = 1.0; // Time step

  // Simple N-Body Gravity (naive O(N^2))
  // We update velocities based on gravity from ALL other bodies
  for (size_t i = 0; i < bodies.size(); ++i) {
    for (size_t j = 0; j < bodies.size(); ++j) {
      if (i == j)
        continue;
      // cout << "Gravity: " << G << endl;
      bodies[i].applyGravity(bodies[j], G);
    }
  }

  // Update positions
  for (SolarPhysics::CelestialBody &body : bodies) {
    // cout << "DT: " << dt << endl;
    body.update(dt);
  }

  [self setNeedsDisplay:YES]; // Trigger drawRect
}

- (void)drawAnother:(NSRect)dirtyRect {
  // 1. Fill Background (Space is dark)
  [[NSColor blackColor] setFill];
  NSRectFill(dirtyRect);

  CGContextRef context = [[NSGraphicsContext currentContext] CGContext];

  // 2. Center the coordinate system
  double midX = self.bounds.size.width / 2.0;
  double midY = self.bounds.size.height / 2.0;

  // 3. Draw Bodies
  for (const SolarPhysics::CelestialBody &body : bodies) {
    CGContextSetRGBFillColor(context, body.r, body.g, body.b, 1.0);

    // Convert physics position (center 0,0) to view coordinates + offset
    double drawX = midX + body.position.x - body.radius;
    double drawY = midY + body.position.y - body.radius;

    CGRect rect = CGRectMake(drawX, drawY, body.radius * 2, body.radius * 2);
    CGContextFillEllipseInRect(context, rect);
  }
}

- (void)drawMyProgess:(NSRect)dirtyRect {
  [[NSColor blackColor] setFill];
  NSRectFill(self.bounds);

  // Sun
  [[NSColor yellowColor] setFill];
  NSBezierPath *sun =
      [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(380, 280, 80, 80)];
  [sun fill];

  // Earth
  [self drawEarth];

  // Mars
  [self drawMars];
}

- (void)cliChoice:(NSString *)choice withDirtyRect:(NSRect)dirtyRect {
  int choiceInt = [choice intValue];

  if (choiceInt == 1) {
    [self drawAnother:dirtyRect];
  } else {
    [self drawMyProgess:dirtyRect];
  }
}

- (void)drawRect:(NSRect)dirtyRect {

  if (!windowingAndCocoa) {
    windowingAndCocoa = [[WindowingAndCocoa alloc] init];
  }

  NSString *choice = @"1";

  [self cliChoice:choice withDirtyRect:dirtyRect];

  // if (![windowingAndCocoa showConfirmAlert:@"Versi 1.0 atau Progress?"
  //                              withChoice1:@"Versi 1.0"
  //                              withChoice2:@"Progress"]) {
  //   [self drawAnother:dirtyRect];
  //   return;
  // } else {
  //   [self drawMyProgess:dirtyRect];
  //   return;
  // }
}

- (void)drawEarth {
  // Earth
  [[NSColor blueColor] setFill];
  NSBezierPath *earth =
      [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(180, 280, 80, 80)];
  [earth fill];
}

- (void)drawMars {
  // Mars
  [[NSColor redColor] setFill];
  NSBezierPath *mars =
      [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(280, 280, 80, 80)];
  [mars fill];
}

@end

// --- AppDelegate ---

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property(strong, nonatomic) NSWindow *window;
@end

@implementation AppDelegate

- (void)intro:(id)sender {
  if (![self
          showConfirmAlert:@"Apakah Anda yakin ingin menjalankan aplikasi?"]) {
    [NSApp terminate:nil];
  }
  [self showInfo:@"Aplikasi sedang berjalan."];
}

- (void)showInfo:(NSString *)msg {
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = @"Info";
  alert.informativeText = msg;
  [alert runModal];
}

- (BOOL)showConfirmAlert:(NSString *)message {
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = @"Konfirmasi";
  alert.informativeText = message;

  [alert addButtonWithTitle:@"Yes"];
  [alert addButtonWithTitle:@"No"];

  NSModalResponse response = [alert runModal];
  return response == NSAlertFirstButtonReturn;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // [self intro:nil];

  NSRect frame = NSMakeRect(100, 100, 800, 600);
  NSWindowStyleMask style =
      NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
      NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable;

  self.window = [[NSWindow alloc] initWithContentRect:frame
                                            styleMask:style
                                              backing:NSBackingStoreBuffered
                                                defer:NO];

  [self.window setTitle:@"Native Objective-C++ Solar System"];

  // Create and set the SolarSystemView
  SolarSystemView *solarView = [[SolarSystemView alloc] initWithFrame:frame];
  [self.window setContentView:solarView];

  [self.window makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];

  Operator *tugas1 = new Operator();

  cout << "Solar System Simulation Started." << endl;
  [self HelloWorld:10];
  [self keyDown:nil];
}

// Source - https://stackoverflow.com/a/7114807
// Posted by Dair
// Retrieved 2026-02-14, License - CC BY-SA 3.0

- (void)keyDown:(NSEvent *)event {

  if ([event keyCode] == 13) { // For return key
    cout << "Return key pressed" << endl;
  }
  if ([event keyCode] == 9) { // For tab key
    cout << "Tab key pressed" << endl;
  }
}

- (void)HelloWorld:(int)count {
  @autoreleasepool {
    for (int i = 1; i <= count; i++) {
      NSLog(@"%d Hello World", i);
    }
  }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [self showInfo:@"Aplikasi ditutup."];
  cout << "Application will terminate." << endl;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:
    (NSApplication *)sender {
  return YES;
}

@end