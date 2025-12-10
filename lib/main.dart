import 'package:flutter/material.dart'; // Material library for widgets
import 'package:shared_preferences/shared_preferences.dart'; // key-value storage for small settings
import 'package:go_router/go_router.dart'; // named routing for web-friendly navigation

void main() => runApp(const MyApp()); // The entry point to my Dart program

class MyApp extends StatefulWidget {
  // I make it stateful because it will be changing themes and controlling splash/router
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// Holds the App-level state
class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  bool _showSplash = true; // shows animated splash
  late final GoRouter _router; // router for named routes

  @override
  void initState() {
    super.initState();

    // Initialize router with named routes
    _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => HomeScaffold(
            themeMode: _themeMode,
            onThemeChanged: _setTheme,
          ),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => SettingsRouteScreen(
            themeMode: _themeMode,
            onThemeChanged: _setTheme,
          ),
        ),
      ],
    );

    _loadThemeFromPrefs(); // Load previously saved theme mode

    // Splash screen delay to simulate initial loading
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  // Async function: read the saved theme from storage
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance(); // obtain the shared preferences
    final saved = prefs.getString("themeMode") ?? "system"; // try reading the key for theme, fallback to "system" if missing
    setState(() {
      _themeMode = switch (saved) {
      // map the stored string back to a ThemeMode value
        "light" => ThemeMode.light,
        "dark" => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    });
  }

  Future<void> _savedThemeToPrefs(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance(); // get the preference handle
    final asString = switch (mode) {
    // convert enum to string for storage
      ThemeMode.light => "light",
      ThemeMode.dark => "dark",
      ThemeMode.system => "system",
    };
    await prefs.setString("themeMode", asString); // Write to disk asynchronously.
  }

  void _setTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
    _savedThemeToPrefs(mode);
  }

  @override
  Widget build(BuildContext context) {
    // While splash is showing, we keep a simple MaterialApp with the splash page
    if (_showSplash) {
      return MaterialApp(
        title: "Lab 4 - Nav + Toggle + Theme",
        themeMode: _themeMode,
        theme: ThemeData(
          // Light theme definition
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
        ),
        darkTheme: ThemeData(
          // Dark theme definition
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
        ),
        home: const SplashScreen(),
      );
    }

    // After splash, switch to MaterialApp.router that uses GoRouter for named routes
    return MaterialApp.router(
      title: "Lab 4 - Nav + Toggle + Theme",
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      routerConfig: _router,
    );
  }
}

class HomeScaffold extends StatefulWidget {
  // Using a stateful widget because it will change based on index
  const HomeScaffold({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode; // The current theme mode
  final void Function(ThemeMode) onThemeChanged; // Callback to update theme in the parent (MyApp)

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _index = 0; // tab: 0 = Home, 1 = Settings

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to help with responsive behavior for the bottom nav
    final bool isWide = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab 4"),
        actions: [
          // Extra navigation + tooltip (web-friendly, hover shows hint)
          Tooltip(
            message: "Open standalone Settings page (browser back works)",
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Use pushNamed so there IS something to pop afterwards
                context.pushNamed('settings');
              },
            ),
          ),
        ],
      ),
      // Responsive body: tabbed layout on small screens,
      // side-by-side layout on larger screens
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          if (width < 800) {
            // Phone / small screen layout: original tabbed behavior
            return IndexedStack(
              index: _index,
              children: [
                const HomePage(),
                SettingsPage(
                  themeMode: widget.themeMode,
                  onThemeChanged: widget.onThemeChanged,
                ),
              ],
            );
          } else {
            // Wide screen layout: show Home and Settings side by side
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: const HomePage(),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 3,
                  child: SettingsPage(
                    themeMode: widget.themeMode,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              ],
            );
          }
        },
      ),
      // Bottom navigation only on small screens
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) {
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  // stateful because it will be changing
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Holds the toggle state
class _HomePageState extends State<HomePage> {
  bool _isOn = false; // false = red, true = green
  bool _hovering = false; // for hover effect on web
  late Future<void> _loadFuture; // simulate network/data loading

  @override
  void initState() {
    super.initState();
    // Simulate a slow network/data load: show a spinner before content
    _loadFuture = Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _isOn ? Colors.green : Colors.red;

    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading indicator for "slow data"
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Content after data "loads"
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MouseRegion(
                onEnter: (_) => setState(() => _hovering = true),
                onExit: (_) => setState(() => _hovering = false),
                child: Tooltip(
                  message:
                  _isOn ? "Green mode is ON" : "Red mode is ON (OFF state)",
                  child: AnimatedContainer(
                    // similar to a container, but more smooth
                    duration: const Duration(milliseconds: 250),
                    width: _hovering ? 180 : 160,
                    height: _hovering ? 180 : 160,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20), // round corners
                      boxShadow: _hovering
                          ? [
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ]
                          : [],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // space between square and button
              Tooltip(
                message: "Click to toggle the color of the square",
                child: FilledButton.tonal(
                  onPressed: () {
                    setState(() {
                      _isOn = !_isOn;
                    });
                  },
                  child: Text(
                    _isOn ? "Turn OFF (Red)" : "Turn ON (Green)",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// This is the settings *content* widget reused in both tab and route
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final void Function(ThemeMode) onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Left-align title
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Theme",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Tooltip(
                    message:
                    "These theme settings are saved in local storage and persist after refresh.",
                    child: const Icon(Icons.info_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose Light, Dark, or follow System. Saved to SharedPreferences.",
              ),
              const SizedBox(height: 16),
              SegmentedButton<ThemeMode>(
                segments: const [
                  // Define the 3 segments
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text("Light"),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text("Dark"),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.settings_suggest),
                    label: Text("System"),
                  ),
                ],
                selected: {themeMode}, // Which segment is currently selected
                onSelectionChanged: (set) => onThemeChanged(set.first),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// This is the *route screen* at `/settings`
/// It wraps SettingsPage in its own Scaffold with app bar + back button
class SettingsRouteScreen extends StatelessWidget {
  const SettingsRouteScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final void Function(ThemeMode) onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings (Route)"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // If there's something to pop (we came here via pushNamed), pop it.
            // Otherwise, just go directly to the home route.
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('home');
            }
          },
        ),
      ),
      body: SettingsPage(
        themeMode: themeMode,
        onThemeChanged: onThemeChanged,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo, // Splash background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FlutterLogo(size: 120), // Flutter logo
            SizedBox(height: 20),
            Text(
              "Loading Lab 4...",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ), // loading spinner
          ],
        ),
      ),
    );
  }
}
