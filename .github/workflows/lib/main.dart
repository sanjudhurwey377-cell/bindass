import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- DATA MODELS ---
class PostEntity {
  final String id;
  final String authorId;
  final String authorUsername;
  final String authorAvatar;
  final bool isAuthorVerified;
  final String? location;
  final List<String> mediaUrls;
  final String caption;
  final List<String> hashtags;
  final String createdAtFormatted;
  int likesCount;
  int commentsCount;
  bool isLiked;

  PostEntity({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.authorAvatar,
    required this.isAuthorVerified,
    this.location,
    required this.mediaUrls,
    required this.caption,
    required this.hashtags,
    required this.createdAtFormatted,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });
}

class KarmaState {
  final int points;
  KarmaState({this.points = 120});
}

// --- RIVERPOD STATE MANAGEMENT ---
class KarmaNotifier extends StateNotifier<KarmaState> {
  KarmaNotifier() : super(KarmaState());

  void addKarma(int amount) {
    state = KarmaState(points: state.points + amount);
  }
}

final currentUserKarmaProvider = StateNotifierProvider<KarmaNotifier, KarmaState>((ref) {
  return KarmaNotifier();
});

class FeedNotifier extends StateNotifier<AsyncValue<List<PostEntity>>> {
  FeedNotifier() : super(const AsyncValue.loading()) {
    loadInitialPosts();
  }

  void loadInitialPosts() {
    state = AsyncValue.data([
      PostEntity(
        id: '1',
        authorId: 'u1',
        authorUsername: 'alex_creator',
        authorAvatar: 'https://picsum.photos/200/200?random=1',
        isAuthorVerified: true,
        location: 'Mumbai, India',
        mediaUrls: ['https://picsum.photos/600/750?random=2'],
        caption: 'Night vibes and cinematic lights 📸✨',
        hashtags: ['#photography', '#vibes', '#pro'],
        createdAtFormatted: '2 hours ago',
        likesCount: 142,
        commentsCount: 18,
      ),
      PostEntity(
        id: '2',
        authorId: 'u2',
        authorUsername: 'rohit_sharma',
        authorAvatar: 'https://picsum.photos/200/200?random=3',
        isAuthorVerified: false,
        location: 'Goa',
        mediaUrls: ['https://picsum.photos/600/750?random=4'],
        caption: 'Exploring coastal roads 🏍️🌊',
        hashtags: ['#travel', '#rider', '#explore'],
        createdAtFormatted: '5 hours ago',
        likesCount: 89,
        commentsCount: 12,
      ),
    ]);
  }

  void toggleLike(String postId, WidgetRef ref) {
    state.whenData((posts) {
      final updatedList = posts.map((post) {
        if (post.id == postId) {
          final willLike = !post.isLiked;
          if (willLike) {
            ref.read(currentUserKarmaProvider.notifier).addKarma(10);
          }
          return PostEntity(
            id: post.id,
            authorId: post.authorId,
            authorUsername: post.authorUsername,
            authorAvatar: post.authorAvatar,
            isAuthorVerified: post.isAuthorVerified,
            location: post.location,
            mediaUrls: post.mediaUrls,
            caption: post.caption,
            hashtags: post.hashtags,
            createdAtFormatted: post.createdAtFormatted,
            likesCount: willLike ? post.likesCount + 1 : post.likesCount - 1,
            commentsCount: post.commentsCount,
            isLiked: willLike,
          );
        }
        return post;
      }).toList();
      state = AsyncValue.data(updatedList);
    });
  }
}

final feedControllerProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<PostEntity>>>((ref) {
  return FeedNotifier();
});

// --- MAIN ENTRY POINT ---
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bindass',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const FeedScreen(),
    );
  }
}

// --- STORIES TRAY WIDGET ---
class StoriesTrayWidget extends StatelessWidget {
  const StoriesTrayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF6366F1), Color(0xFFEC4899)],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: CachedNetworkImageProvider(
                      'https://picsum.photos/150/150?random=${index + 10}',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  index == 0 ? 'Your Story' : 'User_${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- MAIN FEED SCREEN ---
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedControllerProvider);
    final karmaState = ref.watch(currentUserKarmaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'BINDASS',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xFF38BDF8), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${karmaState.points} pts',
                  style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: feedState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
        data: (posts) => CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: StoriesTrayWidget()),
            const SliverToBoxAdapter(child: Divider(color: Color(0xFF1E293B), height: 1)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PostItemWidget(post: posts[index]),
                childCount: posts.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- POST ITEM COMPONENT ---
class PostItemWidget extends ConsumerStatefulWidget {
  final PostEntity post;
  const PostItemWidget({super.key, required this.post});

  @override
  ConsumerState<PostItemWidget> createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends ConsumerState<PostItemWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.0), weight: 50),
    ]).animate(_animController);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
      }
    });
  }

  void _triggerLike() {
    HapticFeedback.mediumImpact();
    setState(() => _showHeart = true);
    _animController.forward(from: 0.0);
    ref.read(feedControllerProvider.notifier).toggleLike(widget.post.id, ref);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: CachedNetworkImageProvider(post.authorAvatar),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Text(post.authorUsername, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      if (post.isAuthorVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 15, color: Color(0xFF0EA5E9)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: _triggerLike,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: CachedNetworkImage(
                    imageUrl: post.mediaUrls.first,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => Container(color: const Color(0xFF1E293B)),
                    errorWidget: (ctx, url, err) => const Center(child: Icon(Icons.broken_image, color: Colors.white24)),
                  ),
                ),
                if (_showHeart)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: const Icon(Icons.favorite, color: Colors.redAccent, size: 90),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? Colors.redAccent : Colors.white),
                  onPressed: _triggerLike,
                ),
                Text('${post.likesCount}', style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 12),
                const Icon(Icons.chat_bubble_outline, color: Colors.white),
                const SizedBox(width: 6),
                Text('${post.commentsCount}', style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.send_outlined, color: Colors.white),
                  onPressed: () {
                    ref.read(currentUserKarmaProvider.notifier).addKarma(15);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post Shared! +15 Karma points earned!')),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(post.caption, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
