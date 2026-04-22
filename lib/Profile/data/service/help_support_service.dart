class HelpSupportService {
  Future<List<Map<String, dynamic>>> fetchSupportCategories() async {
    return [
      {
        'icon': '🚚',
        'title': 'Delivery Issues.',
        'description': 'For pickup/delivery problems, route confusion, or customer complaints:',
        'contact': '+91632158426'
      },
      {
        'icon': '💰',
        'title': 'Salary & Incentives',
        'description': 'For payment disputes or incentive calculation queries:',
        'contact': '+91632158426'
      },
      {
        'icon': '📱',
        'title': 'App / Technical Issues',
        'description': 'For bugs, app crashes, or login problems:',
        'contact': '+91632158426'
      },
    ];
  }
}