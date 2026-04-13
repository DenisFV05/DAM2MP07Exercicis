import 'package:flutter/material.dart';
import 'app_data.dart';

class ResultsScreen extends StatelessWidget {
  final AppData appData;
  const ResultsScreen({super.key, required this.appData});

  @override
  Widget build(BuildContext context) {
    final ranking = appData.ranking;
    final isWinner = appData.winnerId == appData.myId;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade900,
              isWinner ? Colors.amber.shade900.withValues(alpha: 0.3) : Colors.red.shade900.withValues(alpha: 0.3),
              Colors.grey.shade900,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isWinner ? '🏆' : '💀',
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                isWinner ? 'HAS GUANYAT!' : 'PARTIDA ACABADA',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: isWinner ? Colors.amber : Colors.white,
                ),
              ),
              if (appData.winnerName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Guanyador: ${appData.winnerName}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              // Ranking table
              Container(
                width: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade700,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'RÀNQUING',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Table header
                    Row(
                      children: [
                        const SizedBox(width: 30, child: Text('#', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                        const Expanded(child: Text('Jugador', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 60, child: Text('Kills', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 60, child: Text('Punts', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    ...ranking.map((r) {
                      final isMe = r['id'] == appData.myId;
                      final alive = r['alive'] as bool? ?? false;
                      final rank = r['rank'] as int? ?? 0;
                      final color = _parseColor(r['color'] as String? ?? '#FFFFFF');

                      String medal = '';
                      if (rank == 1) medal = '🥇 ';
                      if (rank == 2) medal = '🥈 ';
                      if (rank == 3) medal = '🥉 ';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isMe ? color.withValues(alpha: 0.15) : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                '$medal$rank',
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.grey.shade400,
                                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${r['name']}${isMe ? ' (Tu)' : ''}',
                                style: TextStyle(
                                  color: alive ? Colors.white : Colors.grey,
                                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                  decoration: alive ? null : TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                '${r['kills']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade300),
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                '${r['score']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => appData.sendRestart(),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'NOVA PARTIDA',
                  style: TextStyle(letterSpacing: 2),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
