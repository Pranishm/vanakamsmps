class NewsItem {
  const NewsItem({required this.title, required this.summary, required this.date});

  final String title;
  final String summary;
  final String date;
}

class ForumTopic {
  const ForumTopic({
    required this.author,
    required this.title,
    required this.replies,
    required this.likes,
  });

  final String author;
  final String title;
  final int replies;
  final int likes;
}

class StoreProduct {
  const StoreProduct({
    required this.name,
    required this.price,
    required this.description,
  });

  final String name;
  final double price;
  final String description;
}

const demoNews = <NewsItem>[
  NewsItem(
    title: 'Season 5 starts now',
    summary: 'New spawn, performance upgrades and fresh economy reset.',
    date: 'Apr 08, 2026',
  ),
  NewsItem(
    title: 'Forum reputation update',
    summary: 'Daily likes and answer quality now improve user ranking.',
    date: 'Apr 04, 2026',
  ),
];

const demoTopics = <ForumTopic>[
  ForumTopic(
    author: 'PixelKnight',
    title: 'Best farms for early survival?',
    replies: 24,
    likes: 46,
  ),
  ForumTopic(
    author: 'LunaCraft',
    title: 'Suggestions for weekend event rewards',
    replies: 13,
    likes: 29,
  ),
];

const demoProducts = <StoreProduct>[
  StoreProduct(
    name: 'VIP Rank',
    price: 7.99,
    description: 'Exclusive cosmetics, chat tag and extra homes.',
  ),
  StoreProduct(
    name: 'Legend Rank',
    price: 14.99,
    description: 'Everything in VIP + premium crate keys weekly.',
  ),
  StoreProduct(
    name: 'Sky Bundle',
    price: 4.99,
    description: 'Starter kit with tools, food and utility perks.',
  ),
];
