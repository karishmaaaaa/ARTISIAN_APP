import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/artisan_model.dart';
import '../../../repositories/artisan_repository.dart';
import '../../../core/errors/result.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for the ArtisanRepository instance
final artisanRepositoryProvider = Provider<ArtisanRepository>((ref) {
  return ArtisanRepository();
});

/// Provider for current artisan profile
final currentArtisanProvider = StreamProvider<ArtisanModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || !user.isArtisan) {
    return const Stream.empty();
  }
  
  final repo = ref.watch(artisanRepositoryProvider);
  return repo.artisanStream(user.id);
});

/// Provider for a specific artisan by ID
final artisanProvider = FutureProvider.family<ArtisanModel?, String>(
  (ref, artisanId) async {
    final repo = ref.watch(artisanRepositoryProvider);
    final result = await repo.getArtisan(artisanId);
    return result.dataOrNull;
  },
);

/// Provider for artisan with user data
final artisanWithUserProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, artisanId) async {
    final repo = ref.watch(artisanRepositoryProvider);
    final result = await repo.getArtisanWithUser(artisanId);
    return result.dataOrNull;
  },
);

/// Provider for all artisans (for browsing)
final allArtisansProvider = FutureProvider<List<ArtisanModel>>((ref) async {
  final repo = ref.watch(artisanRepositoryProvider);
  final result = await repo.getAllArtisans();
  return result.getOrElse([]);
});

/// Provider for featured artisans
final featuredArtisansProvider = FutureProvider<List<ArtisanModel>>((ref) async {
  final repo = ref.watch(artisanRepositoryProvider);
  final result = await repo.getFeaturedArtisans();
  return result.getOrElse([]);
});

/// Provider for top artisans by sales
final topArtisansProvider = FutureProvider<List<ArtisanModel>>((ref) async {
  final repo = ref.watch(artisanRepositoryProvider);
  final result = await repo.getTopArtisans();
  return result.getOrElse([]);
});

/// Provider for artisan dashboard stats
final artisanStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || !user.isArtisan) {
    return {};
  }
  
  final repo = ref.watch(artisanRepositoryProvider);
  final result = await repo.getArtisanStats(user.id);
  return result.getOrElse({});
});

/// State for artisan profile editing
class ArtisanProfileState {
  final ArtisanModel? artisan;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const ArtisanProfileState({
    this.artisan,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  ArtisanProfileState copyWith({
    ArtisanModel? artisan,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
  }) {
    return ArtisanProfileState(
      artisan: artisan ?? this.artisan,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Notifier for artisan profile management
class ArtisanProfileNotifier extends StateNotifier<ArtisanProfileState> {
  final ArtisanRepository _repository;
  final String _artisanId;

  ArtisanProfileNotifier(this._repository, this._artisanId)
      : super(const ArtisanProfileState()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_artisanId.isEmpty) return;
    
    state = state.copyWith(isLoading: true);
    final result = await _repository.getArtisan(_artisanId);
    result.when(
      success: (artisan) => state = state.copyWith(
        artisan: artisan,
        isLoading: false,
      ),
      failure: (e) => state = state.copyWith(
        error: e.message,
        isLoading: false,
      ),
    );
  }

  /// Update artisan profile
  Future<bool> updateProfile({
    String? shopName,
    String? description,
    List<String>? specializations,
    String? location,
  }) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);

    final result = await _repository.updateArtisan(
      artisanId: _artisanId,
      shopName: shopName,
      description: description,
      specializations: specializations,
      location: location,
    );

    return result.when(
      success: (artisan) {
        state = state.copyWith(
          artisan: artisan,
          isSaving: false,
          successMessage: 'Profile updated successfully',
        );
        return true;
      },
      failure: (e) {
        state = state.copyWith(isSaving: false, error: e.message);
        return false;
      },
    );
  }

  /// Upload banner image
  Future<bool> uploadBanner(File imageFile) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);

    final result = await _repository.uploadBannerImage(
      artisanId: _artisanId,
      imageFile: imageFile,
    );

    return result.when(
      success: (url) {
        state = state.copyWith(
          artisan: state.artisan?.copyWith(bannerImageUrl: url),
          isSaving: false,
          successMessage: 'Banner updated successfully',
        );
        return true;
      },
      failure: (e) {
        state = state.copyWith(isSaving: false, error: e.message);
        return false;
      },
    );
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

/// Provider for artisan profile notifier
final artisanProfileNotifierProvider =
    StateNotifierProvider<ArtisanProfileNotifier, ArtisanProfileState>((ref) {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(artisanRepositoryProvider);
  return ArtisanProfileNotifier(repo, user?.id ?? '');
});

/// State for artisan browsing with search
class ArtisanBrowseState {
  final List<ArtisanModel> artisans;
  final bool isLoading;
  final String? searchQuery;
  final List<String>? specializationFilter;
  final String? error;

  const ArtisanBrowseState({
    this.artisans = const [],
    this.isLoading = false,
    this.searchQuery,
    this.specializationFilter,
    this.error,
  });

  ArtisanBrowseState copyWith({
    List<ArtisanModel>? artisans,
    bool? isLoading,
    String? searchQuery,
    List<String>? specializationFilter,
    String? error,
  }) {
    return ArtisanBrowseState(
      artisans: artisans ?? this.artisans,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      specializationFilter: specializationFilter ?? this.specializationFilter,
      error: error,
    );
  }
}

/// Notifier for browsing artisans
class ArtisanBrowseNotifier extends StateNotifier<ArtisanBrowseState> {
  final ArtisanRepository _repository;

  ArtisanBrowseNotifier(this._repository) : super(const ArtisanBrowseState()) {
    loadArtisans();
  }

  Future<void> loadArtisans() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getAllArtisans(
      searchQuery: state.searchQuery,
      specializations: state.specializationFilter,
    );

    result.when(
      success: (artisans) => state = state.copyWith(
        artisans: artisans,
        isLoading: false,
      ),
      failure: (e) => state = state.copyWith(
        error: e.message,
        isLoading: false,
      ),
    );
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
    loadArtisans();
  }

  void setSpecializationFilter(List<String>? specializations) {
    state = state.copyWith(specializationFilter: specializations);
    loadArtisans();
  }

  void clearFilters() {
    state = const ArtisanBrowseState();
    loadArtisans();
  }
}

/// Provider for artisan browsing
final artisanBrowseProvider =
    StateNotifierProvider<ArtisanBrowseNotifier, ArtisanBrowseState>((ref) {
  final repo = ref.watch(artisanRepositoryProvider);
  return ArtisanBrowseNotifier(repo);
});
