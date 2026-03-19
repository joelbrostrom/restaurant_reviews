import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/logger.dart';

const _tag = 'Firebase';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Auth ---

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(String email, String password) async {
    Log.d(_tag, 'Signing up: $email');
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        await _db.collection('profiles').doc(cred.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        Log.d(_tag, 'Sign-up complete for ${cred.user!.uid}');
      }
      return cred;
    } catch (e, stack) {
      Log.e(_tag, 'Sign-up failed for $email', e, stack);
      rethrow;
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    Log.d(_tag, 'Signing in: $email');
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Log.d(_tag, 'Sign-in complete for ${cred.user?.uid}');
      return cred;
    } catch (e, stack) {
      Log.e(_tag, 'Sign-in failed for $email', e, stack);
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    Log.d(_tag, 'Signing in with Google');
    try {
      final provider = GoogleAuthProvider();
      final cred = await _auth.signInWithPopup(provider);
      if (cred.additionalUserInfo?.isNewUser == true && cred.user != null) {
        await _db.collection('profiles').doc(cred.user!.uid).set({
          'email': cred.user!.email,
          'displayName': cred.user!.displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        Log.d(_tag, 'New Google user profile created: ${cred.user!.uid}');
      }
      Log.d(_tag, 'Google sign-in complete for ${cred.user?.uid}');
      return cred;
    } catch (e, stack) {
      Log.e(_tag, 'Google sign-in failed', e, stack);
      rethrow;
    }
  }

  Future<void> signOut() {
    Log.d(_tag, 'Signing out');
    return _auth.signOut();
  }

  // --- Profile ---

  Future<void> updateProfile({
    String? displayName,
    String? selectedCity,
    double? latitude,
    double? longitude,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (displayName != null) data['displayName'] = displayName;
    if (selectedCity != null) data['selectedCity'] = selectedCity;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    await _db
        .collection('profiles')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('profiles').doc(uid).get();
    return doc.data();
  }

  // --- Favorites ---

  String _favoriteDocId(String restaurantId, String provider) {
    final uid = currentUser!.uid;
    return '${uid}_${restaurantId}_$provider';
  }

  Future<void> addFavorite({
    required String restaurantId,
    required String provider,
    required String restaurantName,
    String? cachedCity,
    String? cachedImageUrl,
  }) async {
    final uid = currentUser!.uid;
    final docId = _favoriteDocId(restaurantId, provider);
    Log.d(_tag, 'Adding favorite: $docId');
    try {
      await _db.collection('favorites').doc(docId).set({
        'userId': uid,
        'restaurantId': restaurantId,
        'provider': provider,
        'restaurantName': restaurantName,
        'cachedCity': cachedCity,
        'cachedImageUrl': cachedImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      Log.e(_tag, 'addFavorite failed: $docId', e, stack);
      rethrow;
    }
  }

  Future<void> removeFavorite(String restaurantId, String provider) async {
    final docId = _favoriteDocId(restaurantId, provider);
    Log.d(_tag, 'Removing favorite: $docId');
    try {
      await _db.collection('favorites').doc(docId).delete();
    } catch (e, stack) {
      Log.e(_tag, 'removeFavorite failed: $docId', e, stack);
      rethrow;
    }
  }

  Future<bool> isFavorite(String restaurantId, String provider) async {
    final docId = _favoriteDocId(restaurantId, provider);
    final doc = await _db.collection('favorites').doc(docId).get();
    return doc.exists;
  }

  Stream<List<Map<String, dynamic>>> watchFavorites() {
    final uid = currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _db
        .collection('favorites')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  // --- Ratings ---

  String _ratingDocId(String restaurantId, String provider) {
    final uid = currentUser!.uid;
    return '${uid}_${restaurantId}_$provider';
  }

  Future<void> setRating({
    required String restaurantId,
    required String provider,
    required int rating,
  }) async {
    final uid = currentUser!.uid;
    final docId = _ratingDocId(restaurantId, provider);
    Log.d(_tag, 'Setting rating $rating for $docId');
    try {
      await _db.collection('ratings').doc(docId).set({
        'userId': uid,
        'restaurantId': restaurantId,
        'provider': provider,
        'rating': rating,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, stack) {
      Log.e(_tag, 'setRating failed: $docId', e, stack);
      rethrow;
    }
  }

  Future<int?> getUserRating(String restaurantId, String provider) async {
    if (!isSignedIn) return null;
    final docId = _ratingDocId(restaurantId, provider);
    final doc = await _db.collection('ratings').doc(docId).get();
    return doc.data()?['rating'] as int?;
  }

  Stream<int?> watchUserRating(String restaurantId, String provider) {
    if (!isSignedIn) return Stream.value(null);
    final docId = _ratingDocId(restaurantId, provider);
    return _db
        .collection('ratings')
        .doc(docId)
        .snapshots()
        .map((snap) => snap.data()?['rating'] as int?);
  }

  /// Get average rating from all users for a restaurant
  Future<double?> getAverageRating(String restaurantId, String provider) async {
    final snap =
        await _db
            .collection('ratings')
            .where('restaurantId', isEqualTo: restaurantId)
            .where('provider', isEqualTo: provider)
            .get();
    if (snap.docs.isEmpty) return null;
    final total = snap.docs.fold<int>(
      0,
      (acc, doc) => acc + (doc.data()['rating'] as int? ?? 0),
    );
    return total / snap.docs.length;
  }
}
