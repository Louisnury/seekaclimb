import 'package:commun/commun.dart';
import 'package:flutter/material.dart';


class NavigationDemoApp extends StatelessWidget {
  const NavigationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Navigation Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: NavigatorWidget(
        initialPage: const HomePage(),
        config: const NavigatorConfig(),
        routes: {
          '/home': (context) => const HomePage(),
          '/profile': (context) => const ProfilePage(),
          '/settings': (context) => const SettingsPage(),
          '/details': (context) => const DetailsPage(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Démonstration du système de navigation personnalisé',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Navigation avec différentes transitions
            const Text(
              'Navigation avec transitions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => context.pushPage(
                const ProfilePage(),
                routeName: '/profile',
              ),
              child: const Text('Profil (Fade)'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () => context.pushPage(
                const SettingsPage(),
                routeName: '/settings',
              ),
              child: const Text('Paramètres (Slide)'),
            ),
            const SizedBox(height: 8),

            const SizedBox(height: 32),

            // Bannières de test
            const Text(
              'Test des bannières:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        context.showSuccess('Opération réussie !'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Succès'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        context.showError('Erreur détectée !'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Erreur'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        context.showInfo('Information importante'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Info'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.showWarning('Attention !'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Warning'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Bannière avec actions
            ElevatedButton(
              onPressed: () => context.showBanner(
                BannerData(
                  message: 'Nouvelle mise à jour disponible',
                  type: BannerType.info,
                  persistent: true,
                  actions: [
                    BannerAction(
                      text: 'Télécharger',
                      onPressed: () =>
                          context.showSuccess('Téléchargement démarré'),
                    ),
                    BannerAction(text: 'Plus tard', onPressed: () {}),
                  ],
                ),
              ),
              child: const Text('Bannière avec actions'),
            ),

            const Spacer(),

            // Informations de navigation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Pages dans l\'historique: ${context.navigation.history.length}',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            const Text(
              'Utilisateur Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'demo@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () =>
                  context.pushReplacementPage(const SettingsPage()),
              child: const Text('Aller aux paramètres (remplacer)'),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => context.popToRoot(),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) => context.showInfo(
                  value
                      ? 'Notifications activées'
                      : 'Notifications désactivées',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Mode sombre'),
              trailing: Switch(
                value: false,
                onChanged: (value) => context.showInfo(
                  value ? 'Mode sombre activé' : 'Mode sombre désactivé',
                ),
              ),
            ),
            const Divider(),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.popToRoot(),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Page de détails',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cette page démontre la transition de type "scale". '
              'Vous pouvez voir l\'animation d\'agrandissement lors de l\'ouverture '
              'et de réduction lors de la fermeture.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de navigation:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pages dans l\'historique: ${context.navigation.history.length}',
                    ),
                    Text('Peut revenir en arrière: ${context.canPop()}'),
                    Text(
                      'Bannières actives: ${context.navigation.activeBanners.length}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () => context.showBanner(
                BannerData(
                  message: 'Action effectuée depuis la page détails',
                  type: BannerType.success,
                  duration: const Duration(seconds: 2),
                ),
              ),
              child: const Text('Action avec bannière'),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () =>
                  context.pop('Données depuis la page détails'),
              child: const Text('Retour avec données'),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Système de Navigation Personnalisé',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Cette application démontre l\'utilisation d\'un système de navigation '
              'personnalisé pour Flutter avec les fonctionnalités suivantes:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('• Transitions personnalisées (fade, slide, scale)'),
            Text('• Gestion des bannières avec queue'),
            Text('• Historique de navigation'),
            Text('• Middlewares et guards'),
            Text('• Navigation conditionnelle'),
            Text('• Support du bouton retour Android'),
            SizedBox(height: 16),
            Text(
              'Version: 1.0.0',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
