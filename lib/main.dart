import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const PortfolioApp());

class DeviceUtils {
  static const _desktopThreshold = 600.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width > _desktopThreshold;
  static bool isMobile(BuildContext context) => !isDesktop(context);
}

class AppTheme {
  static ThemeData getTheme(bool isDark) => ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      );
}

class ThemeController {
  static final themeNotifier = ValueNotifier<bool>(true);

  static void toggleTheme() => themeNotifier.value = !themeNotifier.value;
}

class AppRoutes {
  static const routes = {
    '/': 0,
    '/projects': 1,
    '/articles': 2,
    // '/contact': 3,
  };

  static GoRouter getRouter() => GoRouter(
        routes: routes.entries
            .map((entry) => GoRoute(
                  path: entry.key,
                  builder: (_, __) => MainScreen(selectedIndex: entry.value),
                ))
            .toList(),
      );

  static String getPath(int index) => routes.keys.elementAt(index);
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Siddhesh Nanche - Portfolio',
      routerConfig: AppRoutes.getRouter(),
      builder: (context, child) => ValueListenableBuilder<bool>(
        valueListenable: ThemeController.themeNotifier,
        builder: (context, isDarkMode, _) => Theme(
          data: AppTheme.getTheme(isDarkMode),
          child: child!,
        ),
      ),
    );
  }
}

class MainScreen extends HookWidget {
  final int selectedIndex;

  const MainScreen({super.key, required this.selectedIndex});

  static const _pages = [
    HomePage(),
    ProjectsPage(),
    ArticlesPage(),
    // ContactPage()
  ];

  static const _navDestinations = [
    (icon: Icons.home, label: 'Home'),
    (icon: Icons.work, label: 'Projects'),
    (icon: Icons.article, label: 'Articles'),
    // (icon: Icons.contact_mail, label: 'Contact'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(selectedIndex);
    final isDesktopView = DeviceUtils.isDesktop(context);

    void navigateTo(int index) {
      currentIndex.value = index;
      context.go(AppRoutes.getPath(index));
    }

    return Scaffold(
      appBar: isDesktopView
          ? null
          : AppBar(
              title: const Text('Siddhesh Nanche'),
              actions: const [_ThemeToggleButton()],
            ),
      body: Row(
        children: [
          if (isDesktopView)
            _DesktopNavigationRail(
              currentIndex: currentIndex.value,
              onDestinationSelected: navigateTo,
            ),
          Expanded(child: _pages[currentIndex.value]),
        ],
      ),
      bottomNavigationBar: DeviceUtils.isMobile(context)
          ? _MobileBottomNavigationBar(
              currentIndex: currentIndex.value,
              onTap: navigateTo,
            )
          : null,
    );
  }
}

class _DesktopNavigationRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const _DesktopNavigationRail({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: MainScreen._navDestinations
          .map((d) => NavigationRailDestination(
                icon: Icon(d.icon),
                label: Text(d.label),
              ))
          .toList(),
      trailing: const Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: _ThemeToggleButton(),
          ),
        ),
      ),
    );
  }
}

class _MobileBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MobileBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: MainScreen._navDestinations
          .map((d) => BottomNavigationBarItem(
                icon: Icon(d.icon),
                label: d.label,
              ))
          .toList(),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return const IconButton(
      icon: Icon(Icons.brightness_6),
      onPressed: ThemeController.toggleTheme,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundColor:
                    Colors.transparent, // Optional for transparency
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/profile.jpeg',
                    fit: BoxFit.fill,
                    width: 160,
                    height: 160,
                  ),
                ),
              ).animate().scale(duration: 600.ms),
              const SizedBox(height: 24),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Mobile Developer',
                    textStyle: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                repeatForever: true,
              ),
              const SizedBox(height: 16),
              Text('iOS | Flutter | Android',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go('/projects'),
                    icon: const Icon(Icons.work),
                    label: const Text('View Projects'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/contact'),
                    icon: const Icon(Icons.contact_mail),
                    label: const Text('Contact Me'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms);
  }
}

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  static const _projects = [
    {
      'title': 'Truepal - iOS & Flutter',
      'description':
          'Developed partner onboarding, integrated MoEngage & Appsflyer, push notifications.',
      'link': 'https://apps.apple.com/in/app/truepal-partner/id6468958746',
    },
    {
      'title': 'Donna for Agents',
      'description':
          'Integrated Alamofire, OneSignal, WebView authentication, and voice search.',
      'link': 'https://apps.apple.com/us/app/donna-for-agents/id6444062364',
    },
    {
      'title': 'Cub McPaws iOS App',
      'description':
          'Migrated Objective-C to Swift, integrated AR features using RealityKit & SceneKit.',
      'link': 'https://apps.apple.com/in/app/cub-mcpaws/id1438225998',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _projects.length,
      itemBuilder: (context, index) =>
          ProjectCard(project: _projects[index]).animate().slideX(
                duration: 500.ms,
                delay: Duration(milliseconds: index * 100),
              ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Map<String, String> project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(project['title']!,
            style: Theme.of(context).textTheme.titleLarge),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(project['description']!),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => launchURL(project['link']!),
        ),
      ),
    );
  }
}

class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

  static const _articles = [
    {
      'title': 'How I Transformed My Flutter Tables and Saved Hours of Work',
      'description':
          'A deep dive into optimizing Flutter tables for better performance and usability.',
      'link':
          'https://medium.com/@siddheshnanche96/how-i-transformed-my-flutter-tables-and-saved-hours-of-work-569b9f51be5e',
    },
    {
      'title': 'Mastering Object Management in Dart',
      'description':
          'Simplify your data with Singleton and CRUD – a flexible solution.',
      'link':
          'https://medium.com/@siddheshnanche96/mastering-object-management-in-dart-simplify-your-data-with-singleton-and-crud-flexible-solution-6059c47421fc',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Articles', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        ..._articles
            .map((article) => ArticleCard(article: article).animate().slideX(
                  duration: 500.ms,
                  delay:
                      Duration(milliseconds: _articles.indexOf(article) * 100),
                )),
      ],
    ).animate().fadeIn(duration: 800.ms);
  }
}

class ArticleCard extends StatelessWidget {
  final Map<String, String> article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(article['title']!,
            style: Theme.of(context).textTheme.titleLarge),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(article['description']!),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => launchURL(article['link']!),
        ),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const _contactItems = [
    (icon: Icons.location_on, text: 'Mumbai, India', url: null),
    (icon: Icons.email, text: 'siddheshnanche96@gmail.com', url: null),
    (
      icon: Icons.link,
      text: 'linkedin.com/in/siddhesh-nanche',
      url: 'https://linkedin.com/in/siddhesh-nanche'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Get in Touch',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          ..._contactItems.map((item) => ContactInfo(
                icon: item.icon,
                text: item.text,
                url: item.url,
              )),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms);
  }
}

class ContactInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? url;

  const ContactInfo(
      {super.key, required this.icon, required this.text, this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: url != null ? () => launchURL(url!) : null,
            child: Text(
              text,
              style: TextStyle(
                color:
                    url != null ? Theme.of(context).colorScheme.primary : null,
                decoration: url != null ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> launchURL(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}
