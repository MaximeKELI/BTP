import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 Test de communication Frontend-Backend');
  print('==========================================');
  
  // Test 1: Vérifier que le backend est accessible
  print('\n1. Test de connectivité backend...');
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:5000/api/workers/workers/types'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      print('✅ Backend accessible (HTTP ${response.statusCode})');
      
      // Lire la réponse
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody);
      
      if (data['types'] != null && data['types'].isNotEmpty) {
        print('✅ API Workers fonctionnelle (${data['types'].length} types trouvés)');
      } else {
        print('❌ API Workers ne retourne pas de données');
      }
    } else {
      print('❌ Backend inaccessible (HTTP ${response.statusCode})');
    }
    client.close();
  } catch (e) {
    print('❌ Erreur de connexion: $e');
  }
  
  // Test 2: Test d'authentification
  print('\n2. Test d\'authentification...');
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://localhost:5000/api/auth/login'));
    request.headers.set('Content-Type', 'application/json');
    
    final loginData = {
      'email': 'test@example.com',
      'password': 'Password123!'
    };
    
    request.write(json.encode(loginData));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      print('✅ Authentification réussie');
      
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody);
      
      if (data['accessToken'] != null) {
        print('✅ Token d\'accès reçu');
        
        // Test 3: Utiliser le token pour accéder aux données protégées
        print('\n3. Test d\'accès aux données protégées...');
        final token = data['accessToken'];
        
        final protectedRequest = await client.getUrl(Uri.parse('http://localhost:5000/api/workers/workers'));
        protectedRequest.headers.set('Authorization', 'Bearer $token');
        final protectedResponse = await protectedRequest.close();
        
        if (protectedResponse.statusCode == 200) {
          print('✅ Accès aux données protégées réussi');
          
          final protectedBody = await protectedResponse.transform(utf8.decoder).join();
          final protectedData = json.decode(protectedBody);
          
          if (protectedData['workers'] != null) {
            print('✅ Données workers récupérées (${protectedData['total']} ouvriers)');
          }
        } else {
          print('❌ Accès aux données protégées échoué (HTTP ${protectedResponse.statusCode})');
        }
      } else {
        print('❌ Token d\'accès non reçu');
      }
    } else {
      print('❌ Authentification échouée (HTTP ${response.statusCode})');
    }
    client.close();
  } catch (e) {
    print('❌ Erreur d\'authentification: $e');
  }
  
  // Test 4: Test des équipements
  print('\n4. Test des équipements...');
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:5000/api/equipment/equipment/categories'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      print('✅ API Equipment accessible');
      
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody);
      
      if (data['categories'] != null && data['categories'].isNotEmpty) {
        print('✅ API Equipment fonctionnelle (${data['categories'].length} catégories trouvées)');
      }
    } else {
      print('❌ API Equipment inaccessible (HTTP ${response.statusCode})');
    }
    client.close();
  } catch (e) {
    print('❌ Erreur Equipment: $e');
  }
  
  print('\n🎉 Test de communication terminé !');
}
