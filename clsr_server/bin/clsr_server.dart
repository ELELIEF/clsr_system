import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:sqlite3/sqlite3.dart';

late Database db;

void main() async {
  // 初始化SQLite数据库
  db = sqlite3.open('clsr_db.sqlite');

  // 可选：初始化表结构（如果不存在则创建）
  db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT
    );
  ''');
  db.execute('''
    CREATE TABLE IF NOT EXISTS seats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      floor TEXT,
      zone TEXT,
      isAvailable INTEGER
    );
  ''');
  db.execute('''
    CREATE TABLE IF NOT EXISTS reservation (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      seat_name TEXT,
      start_time TEXT,
      end_time TEXT
    );
  ''');

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('Server listening on port ${server.port}');
}

Future<Response> _router(Request request) async {
  if (request.url.path == 'login' && request.method == 'POST') {
    final body = await request.readAsString();
    final data = jsonDecode(body);
    final username = data['username'];
    final password = data['password'];

    final result = db.select(
      'SELECT * FROM users WHERE username = ? AND password = ?',
      [username, password],
    );
    if (result.isNotEmpty) {
      return Response.ok(
        '{"success": true}',
        headers: {'content-type': 'application/json'},
      );
    } else {
      return Response.ok(
        '{"success": false, "msg": "用户名或密码错误"}',
        headers: {'content-type': 'application/json'},
      );
    }
  }

  if (request.url.path == 'register' && request.method == 'POST') {
    final body = await request.readAsString();
    final data = jsonDecode(body);
    final username = data['username'];
    final password = data['password'];

    final result = db.select('SELECT * FROM users WHERE username = ?', [
      username,
    ]);
    if (result.isNotEmpty) {
      return Response.ok(
        '{"success": false, "msg": "用户已存在"}',
        headers: {'content-type': 'application/json'},
      );
    }
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [
      username,
      password,
    ]);
    return Response.ok(
      '{"success": true}',
      headers: {'content-type': 'application/json'},
    );
  }

  // ...existing code...
  if (request.url.path == 'seats' && request.method == 'GET') {
    final params = request.url.queryParameters;
    final floor = params['floor'];
    final zone = params['zone'];

    var sql = 'SELECT * FROM seats WHERE 1=1';
    var sqlParams = <dynamic>[];
    if (floor != null && floor != '全部') {
      sql += ' AND floor = ?';
      sqlParams.add(floor);
    }
    if (zone != null && zone != '全部') {
      sql += ' AND zone = ?';
      sqlParams.add(zone);
    }

    final results = db.select(sql, sqlParams);
    var seats =
        results
            .map(
              (row) => {
                'id': row['id'],
                'name': row['name'],
                'floor': row['floor'],
                'zone': row['zone'],
                'isAvailable': row['isAvailable'] == 1,
              },
            )
            .toList();

    return Response.ok(
      jsonEncode({'seats': seats}),
      headers: {'content-type': 'application/json'},
    );
  }
  // ...existing code...

  if (request.url.pathSegments.isNotEmpty &&
      request.url.pathSegments.first == 'seat' &&
      request.method == 'GET') {
    final id = request.url.queryParameters['id'];
    if (id == null) {
      return Response.ok(
        jsonEncode({'success': false, 'msg': '缺少id参数'}),
        headers: {'content-type': 'application/json'},
      );
    }
    // 用db.select替换conn.query
    final results = db.select('SELECT * FROM seats WHERE id = ?', [id]);
    if (results.isEmpty) {
      return Response.ok(
        jsonEncode({'success': false, 'msg': '未找到该座位'}),
        headers: {'content-type': 'application/json'},
      );
    }
    final row = results.first;
    final seat = {
      'id': row['id'],
      'name': row['name'],
      'floor': row['floor'],
      'zone': row['zone'],
      'isAvailable': row['isAvailable'] == 1 || row['isAvailable'] == true,
    };
    return Response.ok(
      jsonEncode({'success': true, 'seat': seat}),
      headers: {'content-type': 'application/json'},
    );
  }

  if (request.url.path == 'reserve' && request.method == 'POST') {
    final body = await request.readAsString();
    final data = jsonDecode(body);
    final username = data['username'];
    final seatName = data['seat_name'];
    final startTime = data['start_time'];
    final endTime = data['end_time'];

    // 检查时间冲突
    final conflict = db.select(
      'SELECT * FROM reservation WHERE seat_name = ? AND '
      '((start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?))',
      [seatName, endTime, endTime, startTime, startTime],
    );
    if (conflict.isNotEmpty) {
      return Response.ok(
        jsonEncode({'success': false, 'msg': '该时间段已被预约'}),
        headers: {'content-type': 'application/json'},
      );
    }

    db.execute(
      'INSERT INTO reservation (username, seat_name, start_time, end_time) VALUES (?, ?, ?, ?)',
      [username, seatName, startTime, endTime],
    );
    // 同时更新座位状态为不可用
    db.execute('UPDATE seats SET isAvailable = 0 WHERE name = ?', [seatName]);
    return Response.ok(
      jsonEncode({'success': true}),
      headers: {'content-type': 'application/json'},
    );
  }

  if (request.url.path == 'reservations' && request.method == 'GET') {
    final username = request.url.queryParameters['username'];
    if (username == null || username.isEmpty) {
      return Response.ok(
        jsonEncode({'success': false, 'msg': '缺少用户名'}),
        headers: {'content-type': 'application/json'},
      );
    }
    final results = db.select(
      'SELECT seat_name, start_time, end_time FROM reservation WHERE username = ? ORDER BY start_time DESC',
      [username],
    );
    final records =
        results
            .map(
              (row) => {
                'seatName': row['seat_name'],
                'startTime': row['start_time'].toString(),
                'endTime': row['end_time'].toString(),
              },
            )
            .toList();
    return Response.ok(
      jsonEncode({'success': true, 'records': records}),
      headers: {'content-type': 'application/json'},
    );
  }

  return Response.notFound('Not Found');
}
