import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:match_day/Providers/authDaoProvider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:match_day/DAO/auth_dao.dart';

import 'auth_test.mocks.dart';

class MockUserCredential extends Mock implements UserCredential {}

// Genera i mock per AuthDao e FirebaseAuth
@GenerateMocks([AuthDao, FirebaseAuth, BuildContext, GlobalKey, FormState])
Future<void> main() async {
  // Inizializza Firebase per i test
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Inizializza il binding di test
  await Firebase.initializeApp();
  late AuthDaoProvider authProvider;
  late MockAuthDao mockAuthDao;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockBuildContext mockBuildContext;
  late MockGlobalKey<FormState> mockFormKey;
  late MockFormState mockFormState;

  setUp(() {
    mockAuthDao = MockAuthDao();
    mockFirebaseAuth = MockFirebaseAuth();
    mockBuildContext = MockBuildContext();
    mockFormKey = MockGlobalKey<FormState>();
    mockFormState = MockFormState();

    // Inizializza AuthDaoProvider con il mock di AuthDao
    authProvider = AuthDaoProvider();
    authProvider.authDao =
        mockAuthDao; // Sostituiamo l'istanza reale con il mock
  });

  group('AuthDaoProvider Tests', () {
    test('createAccount chiama AuthDao.createAccount', () async {
      // Configura il comportamento del mock
      when(mockAuthDao.createAccount(any, any, any, any, any, any, any, any))
          .thenAnswer((_) async {});

      // Esegui il metodo createAccount
      authProvider.createAccount(
        'test@example.com',
        'password123',
        'user',
        '123456789',
        'Nome',
        'Cognome',
        mockBuildContext,
        mockFormKey,
      );

      // Verifica che il metodo AuthDao.createAccount sia stato chiamato correttamente
      verify(mockAuthDao.createAccount(
        'test@example.com',
        'password123',
        '123456789',
        'Nome',
        'Cognome',
        'user',
        mockBuildContext,
        mockFormKey,
      )).called(1);
    });

    test('signIn chiama AuthDao.login', () async {
      // Configura il comportamento del mock
      when(mockAuthDao.login(any, any, any)).thenAnswer((_) async {});

      // Esegui il metodo signIn
      await authProvider.signIn(
          'test@example.com', 'password123', mockBuildContext);

      // Verifica che il metodo AuthDao.login sia stato chiamato correttamente
      verify(mockAuthDao.login(
              'test@example.com', 'password123', mockBuildContext))
          .called(1);
    });

    test('signInCred chiama AuthDao.loginAndReturnUserCredential', () async {
      // Configura il comportamento del mock
      when(mockAuthDao.loginAndReturnUserCredential(any, any, any))
          .thenAnswer((_) async => MockUserCredential());

      // Esegui il metodo signInCred
      await authProvider.signInCred(
          'test@example.com', 'password123', mockBuildContext);

      // Verifica che il metodo AuthDao.loginAndReturnUserCredential sia stato chiamato correttamente
      verify(mockAuthDao.loginAndReturnUserCredential(
        'test@example.com',
        'password123',
        mockBuildContext,
      )).called(1);
    });

    test('sendPasswordResetEmail chiama AuthDao.resetPassword', () async {
      // Configura il comportamento del mock
      when(mockAuthDao.resetPassword(any, any)).thenAnswer((_) async {});

      // Esegui il metodo sendPasswordResetEmail
      await authProvider.sendPasswordResetEmail(
          mockBuildContext, 'test@example.com');

      // Verifica che il metodo AuthDao.resetPassword sia stato chiamato correttamente
      verify(mockAuthDao.resetPassword('test@example.com', mockBuildContext))
          .called(1);
    });

    test('getUserRole chiama AuthDao.getUserRole', () async {
      // Configura il comportamento del mock
      when(mockAuthDao.getUserRole()).thenAnswer((_) async => 'user');

      // Esegui il metodo getUserRole
      var role = await authProvider.getUserRole();

      // Verifica che il metodo AuthDao.getUserRole sia stato chiamato correttamente
      verify(mockAuthDao.getUserRole()).called(1);
      expect(role, 'user');
    });

    test('logout chiama FirebaseAuth.signOut e naviga correttamente', () async {
      // Configura il comportamento del mock
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Esegui il metodo logout
      await authProvider.logout(mockBuildContext);

      // Verifica che FirebaseAuth.signOut sia stato chiamato
      verify(mockFirebaseAuth.signOut()).called(1);
    });
  });
}
