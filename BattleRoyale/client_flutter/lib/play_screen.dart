import 'dart:math' as math;
import 'dart:ui' as ui;

import 'app_data.dart';
import 'game_app.dart';
import 'libgdx_compat/game_framework.dart';
import 'libgdx_compat/gdx.dart';
import 'waiting_room_screen.dart';

// ─── BattleRoyale Play Screen ─────────────────────────────────────────────────
// Renders the BattleRoyale game world: walls, tanks, bullets, health items.
// Uses ShapeRenderer for all drawing (no Games-Tool sprites needed).

class PlayScreen extends ScreenAdapter {
  static const double leaderboardWidth = 240;
  static const double leaderboardPadding = 12;

  static final ui.Color bgColor = const ui.Color(0xFF1A1A2E);
  static final ui.Color wallColor = const ui.Color(0xFF4A4E69);
  static final ui.Color healthItemColor = const ui.Color(0xFF2ECC71);
  static final ui.Color bulletColor = const ui.Color(0xFFFFE07A);
  static final ui.Color healthBarBg = const ui.Color(0xFF333333);
  static final ui.Color healthBarFg = const ui.Color(0xFF2ECC71);
  static final ui.Color healthBarLow = const ui.Color(0xFFE74C3C);
  static final ui.Color panelBg = const ui.Color(0xCC0D1117);
  static final ui.Color panelBorder = const ui.Color(0xFF58A6FF);
  static final ui.Color textColorTitle = const ui.Color(0xFFFFFFFF);
  static final ui.Color textColorDim = const ui.Color(0xFF8B949E);
  static final ui.Color overlayColor = const ui.Color(0xCC000000);

  final GameApp game;

  // World → screen mapping
  double _worldScale = 1.0;
  double _worldOffsetX = 0;
  double _worldOffsetY = 0;

  String _lastSubmittedDirection = 'none';

  PlayScreen(this.game);

  @override
  void render(double delta) {
    final AppData appData = game.getAppData();

    // If waiting phase → go back to waiting room
    if (appData.phase == MatchPhase.waiting ||
        appData.phase == MatchPhase.connecting) {
      _submitDirection(appData, 'none');
      game.setScreen(WaitingRoomScreen(game));
      return;
    }

    final double screenW = Gdx.graphics.getWidth().toDouble();
    final double screenH = Gdx.graphics.getHeight().toDouble();
    final double gameAreaW = screenW - leaderboardWidth;

    // Calculate world→screen scale (letterbox into gameAreaW × screenH)
    _updateWorldTransform(appData, gameAreaW, screenH);

    // ── Input ──────────────────────────────────────────────────────────────
    _submitDirection(appData, _readCurrentDirection());
    _handleShootInput(appData);

    // ── Draw ───────────────────────────────────────────────────────────────
    final ShapeRenderer shapes = game.getShapeRenderer();

    // Background
    shapes.begin(ShapeType.filled);
    shapes.setColor(bgColor);
    shapes.rect(0, 0, screenW, screenH);
    shapes.end();

    // Clip to game area (push transform)
    final ui.Canvas canvas = Gdx.graphics.getCanvas();
    canvas.save();
    canvas.translate(_worldOffsetX, _worldOffsetY);
    canvas.scale(_worldScale, _worldScale);

    // Walls
    shapes.begin(ShapeType.filled);
    shapes.setColor(wallColor);
    for (final BattleRoyaleWall wall in appData.walls) {
      shapes.rect(wall.x, wall.y, wall.w, wall.h);
    }
    shapes.end();

    // Health items (green cross)
    shapes.begin(ShapeType.filled);
    shapes.setColor(healthItemColor);
    for (final BattleRoyaleHealthItem item in appData.healthItems) {
      final double cx = item.x + item.width / 2;
      final double cy = item.y + item.height / 2;
      final double arm = item.width * 0.35;
      final double thick = item.width * 0.2;
      shapes.rect(cx - thick, cy - arm, thick * 2, arm * 2);
      shapes.rect(cx - arm, cy - thick, arm * 2, thick * 2);
    }
    shapes.end();

    // Players (colored circles + health bars)
    _renderPlayers(shapes, appData);

    // Bullets
    shapes.begin(ShapeType.filled);
    shapes.setColor(bulletColor);
    for (final BattleRoyaleBullet bullet in appData.bullets) {
      shapes.circle(bullet.x, bullet.y, bullet.size, 8);
    }
    shapes.end();

    // Restore canvas
    canvas.restore();

    // Ranking panel
    _renderRankingPanel(shapes, appData, gameAreaW, screenH);

    // Winner overlay
    if (appData.phase == MatchPhase.finished) {
      _renderWinnerOverlay(shapes, appData, gameAreaW, screenH);
    }
  }

  void _renderPlayers(ShapeRenderer shapes, AppData appData) {
    final String? localId = appData.playerId;

    for (final MultiplayerPlayer player in appData.players) {
      if (!player.alive) continue;

      final ui.Color tankColor = _parseColor(player.color);
      final double cx = player.x + player.width / 2;
      final double cy = player.y + player.height / 2;
      final double radius = player.width / 2;

      // Tank body circle
      shapes.begin(ShapeType.filled);
      shapes.setColor(tankColor.withAlpha(player.id == localId ? 255 : 180));
      shapes.circle(cx, cy, radius, 12);
      shapes.end();

      // Outline for local player
      if (player.id == localId) {
        shapes.begin(ShapeType.line);
        shapes.setColor(const ui.Color(0xFFFFE07A));
        shapes.circle(cx, cy, radius + 3, 16);
        shapes.end();
      }

      // Direction indicator (cannon)
      _renderCannon(shapes, player, tankColor);

      // Health bar above player
      _renderHealthBar(shapes, player);
    }

    // Dead players (faint X)
    for (final MultiplayerPlayer player in appData.players) {
      if (player.alive) continue;
      final double cx = player.x + player.width / 2;
      final double cy = player.y + player.height / 2;
      final double r = player.width / 3;
      shapes.begin(ShapeType.line);
      shapes.setColor(const ui.Color(0x99E74C3C));
      shapes.line(cx - r, cy - r, cx + r, cy + r);
      shapes.line(cx + r, cy - r, cx - r, cy + r);
      shapes.end();
    }
  }

  void _renderCannon(ShapeRenderer shapes, MultiplayerPlayer player, ui.Color color) {
    final double cx = player.x + player.width / 2;
    final double cy = player.y + player.height / 2;
    final double angle = _directionToAngle(player.direction);
    final double length = player.width * 0.7;
    final double endX = cx + math.cos(angle) * length;
    final double endY = cy + math.sin(angle) * length;

    shapes.begin(ShapeType.line);
    shapes.setColor(color.withAlpha(200));
    shapes.line(cx, cy, endX, endY);
    shapes.end();
  }

  void _renderHealthBar(ShapeRenderer shapes, MultiplayerPlayer player) {
    final double barW = player.width * 1.2;
    final double barH = 4.0;
    final double barX = player.x + (player.width - barW) / 2;
    final double barY = player.y - 8;
    final double hpRatio = player.maxHealth > 0
        ? (player.health / player.maxHealth).clamp(0.0, 1.0)
        : 0.0;

    shapes.begin(ShapeType.filled);
    shapes.setColor(healthBarBg);
    shapes.rect(barX, barY, barW, barH);
    final ui.Color barColor = hpRatio > 0.4 ? healthBarFg : healthBarLow;
    shapes.setColor(barColor);
    shapes.rect(barX, barY, barW * hpRatio, barH);
    shapes.end();
  }

  void _renderRankingPanel(
    ShapeRenderer shapes,
    AppData appData,
    double gameAreaW,
    double screenH,
  ) {
    final double panelX = gameAreaW;

    // Panel background
    shapes.begin(ShapeType.filled);
    shapes.setColor(panelBg);
    shapes.rect(panelX, 0, leaderboardWidth, screenH);
    shapes.end();

    shapes.begin(ShapeType.line);
    shapes.setColor(panelBorder);
    shapes.rect(panelX, 0, leaderboardWidth, screenH);
    shapes.end();

    // Draw text using SpriteBatch + BitmapFont
    final SpriteBatch batch = game.getBatch();
    final BitmapFont font = game.getFont();
    batch.begin();

    font.getData().setScale(1.1);
    font.setColor(textColorTitle);
    font.drawText('BattleRoyale', panelX + leaderboardPadding, 28);
    font.getData().setScale(0.85);
    font.setColor(textColorDim);

    final String phaseText = appData.phase == MatchPhase.playing
        ? 'Playing'
        : appData.phase == MatchPhase.waiting
            ? 'Waiting... ${appData.countdownSeconds}s'
            : appData.phase == MatchPhase.finished
                ? 'Finished'
                : 'Connecting...';
    font.drawText(phaseText, panelX + leaderboardPadding, 48);

    font.getData().setScale(0.9);
    double rowY = 80;
    for (final RankingEntry entry in appData.ranking) {
      final String prefix = entry.alive ? '🔴' : '💀';
      final String line =
          '#${entry.rank} $prefix ${entry.name.length > 10 ? entry.name.substring(0, 10) : entry.name}';
      final ui.Color entryColor =
          entry.id == appData.playerId ? const ui.Color(0xFFFFE07A) : textColorTitle;
      font.setColor(entryColor);
      font.drawText(line, panelX + leaderboardPadding, rowY);
      font.getData().setScale(0.75);
      font.setColor(textColorDim);
      font.drawText(
          'K:${entry.kills}  Score:${entry.score}',
          panelX + leaderboardPadding + 10,
          rowY + 16);
      font.getData().setScale(0.9);
      rowY += 44;
    }

    font.getData().setScale(1);
    batch.end();
  }

  void _renderWinnerOverlay(
    ShapeRenderer shapes,
    AppData appData,
    double gameAreaW,
    double screenH,
  ) {
    shapes.begin(ShapeType.filled);
    shapes.setColor(overlayColor);
    shapes.rect(0, 0, gameAreaW, screenH);
    shapes.end();

    final SpriteBatch batch = game.getBatch();
    final BitmapFont font = game.getFont();
    batch.begin();

    final String title = appData.winnerName.isNotEmpty
        ? '🏆 ${appData.winnerName} wins!'
        : 'Match Finished!';

    font.getData().setScale(2.0);
    font.setColor(const ui.Color(0xFFFFE07A));
    font.drawText(title, gameAreaW * 0.1, screenH * 0.44);

    font.getData().setScale(1.0);
    font.setColor(const ui.Color(0xFFD8FFE3));
    font.drawText('Press Restart to play again', gameAreaW * 0.2, screenH * 0.54);
    font.getData().setScale(1);

    batch.end();
  }

  @override
  void resize(int width, int height) {
    // Will recalculate on next render
  }

  @override
  void dispose() {
    _submitDirection(game.getAppData(), 'none');
  }

  // ─── World → Screen transform ──────────────────────────────────────────────

  void _updateWorldTransform(AppData appData, double areaW, double areaH) {
    if (appData.worldWidth <= 0 || appData.worldHeight <= 0) return;
    final double scaleX = areaW / appData.worldWidth;
    final double scaleY = areaH / appData.worldHeight;
    _worldScale = math.min(scaleX, scaleY);
    final double drawW = appData.worldWidth * _worldScale;
    final double drawH = appData.worldHeight * _worldScale;
    _worldOffsetX = (areaW - drawW) / 2;
    _worldOffsetY = (areaH - drawH) / 2;
  }

  // Convert world coordinates to screen (removed unused methods)

  // ─── Input ─────────────────────────────────────────────────────────────────

  void _submitDirection(AppData appData, String direction) {
    if (_lastSubmittedDirection == direction) return;
    _lastSubmittedDirection = direction;
    appData.updateMovementDirection(direction);
  }

  String _readCurrentDirection() {
    final bool left = Gdx.input.isKeyPressed(Input.keys.left) ||
        Gdx.input.isKeyPressed(Input.keys.a);
    final bool right = Gdx.input.isKeyPressed(Input.keys.right) ||
        Gdx.input.isKeyPressed(Input.keys.d);
    final bool up = Gdx.input.isKeyPressed(Input.keys.up) ||
        Gdx.input.isKeyPressed(Input.keys.w);
    final bool down = Gdx.input.isKeyPressed(Input.keys.down) ||
        Gdx.input.isKeyPressed(Input.keys.s);

    if (up && left) return 'upLeft';
    if (up && right) return 'upRight';
    if (down && left) return 'downLeft';
    if (down && right) return 'downRight';
    if (up) return 'up';
    if (down) return 'down';
    if (left) return 'left';
    if (right) return 'right';
    return 'none';
  }

  void _handleShootInput(AppData appData) {
    if (Gdx.input.justTouched()) {
      final MultiplayerPlayer? local = appData.localPlayer;
      if (local != null) {
        final double mx = Gdx.input.getX().toDouble();
        final double my = Gdx.input.getY().toDouble();

        // Convert mouse screen pos to world pos
        final double worldMouseX = (mx - _worldOffsetX) / _worldScale;
        final double worldMouseY = (my - _worldOffsetY) / _worldScale;

        final double playerCX = local.x + local.width / 2;
        final double playerCY = local.y + local.height / 2;

        final double angle = math.atan2(
          worldMouseY - playerCY,
          worldMouseX - playerCX,
        );
        appData.sendShoot(angle);
      }
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  double _directionToAngle(String direction) {
    switch (direction) {
      case 'right': return 0;
      case 'downRight': return math.pi / 4;
      case 'down': return math.pi / 2;
      case 'downLeft': return 3 * math.pi / 4;
      case 'left': return math.pi;
      case 'upLeft': return -3 * math.pi / 4;
      case 'up': return -math.pi / 2;
      case 'upRight': return -math.pi / 4;
      default: return 0;
    }
  }

  ui.Color _parseColor(String hexColor) {
    try {
      final String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        final int value = int.parse(hex, radix: 16);
        return ui.Color(0xFF000000 | value);
      }
    } catch (_) {}
    return const ui.Color(0xFFE53935);
  }
}
