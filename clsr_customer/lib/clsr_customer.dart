import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String? globalUsername; // 全局变量，存储当前登录用户名
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '图书馆选座系统',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthPage(),
      routes: {
        '/login': (context) => AuthPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class AuthPage extends StatelessWidget {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 新增标题
                Text(
                  '图书馆选座系统',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 32),
                Icon(Icons.menu_book, size: 80, color: Colors.deepPurple),
                SizedBox(height: 40),
                TextField(
                  controller: _usernameCtrl,
                  decoration: InputDecoration(labelText: '学号/工号'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(labelText: '密码'),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _handleLogin(context),
                  child: Text('登录'),
                ),
                TextButton(
                  onPressed: () => _goToRegister(context),
                  child: Text('注册账号'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请输入学号/工号和密码')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/login'),
        body: '{"username":"$username","password":"$password"}',
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        globalUsername = username; // 登录成功时保存用户名
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('登录失败，请检查账号和密码')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('无法连接服务器')));
    }
  }

  void _goToRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register');
  }
}

class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('注册账号')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameCtrl,
                  decoration: InputDecoration(labelText: '学号/工号'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(labelText: '密码'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(labelText: '确认密码'),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _handleRegister(context),
                  child: Text('注册'),
                ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  child: Text('返回登录'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister(BuildContext context) async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;
    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请填写所有信息')));
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('两次密码不一致')));
      return;
    }
    // 调用注册API
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/register'),
        body: '{"username":"$username","password":"$password"}',
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200 && response.body.contains('success')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('注册成功，请登录')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('注册失败')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('无法连接服务器')));
    }
  }
}

// ...existing code...

class Seat {
  final int id;
  final String name;
  final String floor;
  final String zone;
  final bool isAvailable;

  Seat({
    required this.id,
    required this.name,
    required this.floor,
    required this.zone,
    required this.isAvailable,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'],
      name: json['name'],
      floor: json['floor'].toString(),
      zone: json['zone'].toString(),
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _SeatListPageState createState() => _SeatListPageState();
}

class _SeatListPageState extends State<HomePage> {
  List<Seat> _seats = [];
  String _selectedFloor = '全部';
  String _selectedZone = '全部';

  @override
  void initState() {
    super.initState();
    _fetchSeats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('座位列表'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFloor = value;
                _fetchSeats();
              });
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: '全部', child: Text('全部')),
                  PopupMenuItem(value: '1F', child: Text('1楼')),
                  PopupMenuItem(value: '2F', child: Text('2楼')),
                  PopupMenuItem(value: '3F', child: Text('3楼')),
                ],
            icon: Icon(Icons.filter_alt),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedZone = value;
                _fetchSeats();
              });
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: '全部', child: Text('全部区域')),
                  PopupMenuItem(value: 'A区', child: Text('A区')),
                  PopupMenuItem(value: 'B区', child: Text('B区')),
                  PopupMenuItem(value: 'C区', child: Text('C区')),
                ],
            icon: Icon(Icons.layers),
          ),
          IconButton(
            icon: Icon(Icons.person),
            tooltip: '个人中心',
            onPressed: () async {
              // 等待个人中心页面返回
              final needRefresh = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              if (needRefresh == true) {
                _fetchSeats(); // 返回true时刷新座位列表
              }
            },
          ),
        ],
      ),
      body:
          _seats.isEmpty
              ? Center(child: CircularProgressIndicator())
              : GridView.builder(
                padding: EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _seats.length,
                itemBuilder: (context, index) {
                  final seat = _seats[index];
                  return SeatCard(
                    seat: seat,
                    onTap: () => _goToDetail(context, seat),
                  );
                },
              ),
    );
  }

  void _fetchSeats() async {
    final params = <String, String>{};
    if (_selectedFloor != '全部') params['floor'] = _selectedFloor;
    if (_selectedZone != '全部') params['zone'] = _selectedZone;

    // 新增：传递时间段参数
    final now = DateTime.now();
    final startTime = now.toIso8601String();
    final endTime = now.add(Duration(hours: 1)).toIso8601String();
    params['start_time'] = startTime;
    params['end_time'] = endTime;

    final uri = Uri.http('10.0.2.2:8080', '/seats', params);
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _seats =
              (data['seats'] as List).map((e) => Seat.fromJson(e)).toList();
        });
      } else {
        setState(() {
          _seats = [];
        });
      }
    } catch (e) {
      setState(() {
        _seats = [];
      });
    }
  }

  void _goToDetail(BuildContext context, Seat seat) async {
    // 进入详情页前，拉取最新的座位信息
    final uri = Uri.http('10.0.2.2:8080', '/seat', {'id': seat.id.toString()});
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final detailSeat = Seat.fromJson(data['seat']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeatDetailPage(seat: detailSeat),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('获取座位详情失败')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('无法连接服务器')));
    }
  }
}

// ...existing code...
class SeatCard extends StatelessWidget {
  final Seat seat;
  final VoidCallback onTap;

  const SeatCard({required this.seat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: seat.isAvailable ? Colors.green[100] : Colors.red[100],
      child: InkWell(
        // 修改这里：所有座位都能点击
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                seat.isAvailable ? Icons.event_seat : Icons.block,
                color: seat.isAvailable ? Colors.green : Colors.red,
                size: 36,
              ),
              SizedBox(height: 8),
              Text(seat.name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${seat.floor}楼 ${seat.zone}区',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReservationRecord {
  final String seatName;
  final DateTime startTime;
  final DateTime endTime;

  ReservationRecord({
    required this.seatName,
    required this.startTime,
    required this.endTime,
  });

  factory ReservationRecord.fromJson(Map<String, dynamic> json) {
    return ReservationRecord(
      seatName: json['seatName'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  List<ReservationRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _username = globalUsername ?? '';
    });

    if (_username.isEmpty) {
      setState(() {
        _records = [];
        _loading = false;
      });
      return;
    }

    try {
      final res = await http.get(
        Uri.http('10.0.2.2:8080', '/reservations', {'username': _username}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _records =
              (data['records'] as List)
                  .map((e) => ReservationRecord.fromJson(e))
                  .toList();
          _loading = false;
        });
      } else {
        setState(() {
          _records = [];
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _records = [];
        _loading = false;
      });
    }
  }

  void _cancelReservation(ReservationRecord record) async {
    final username = globalUsername ?? '';
    if (username.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('确认取消预约'),
            content: Text('确定要取消该预约吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('确定'),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/cancel_reservation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'seat_name': record.seatName,
          'start_time': record.startTime.toIso8601String(),
          'end_time': record.endTime.toIso8601String(),
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('取消成功')));
        Navigator.pop(context, true); // 返回并通知 seats 列表刷新
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['msg'] ?? '取消失败')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('网络错误，取消失败')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('个人中心')),
      body: Column(
        children: [
          // 上半部分：用户名
          Container(
            width: double.infinity,
            color: Colors.deepPurple[100],
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Icon(Icons.person, size: 48, color: Colors.deepPurple),
                SizedBox(height: 8),
                Text(
                  _username,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.logout),
                  label: Text('退出登录'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    globalUsername = null;
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                ),
              ],
            ),
          ),
          // 下半部分：预约记录
          Expanded(
            child:
                _loading
                    ? Center(child: CircularProgressIndicator())
                    : _records.isEmpty
                    ? Center(child: Text('暂无预约记录'))
                    : ListView.builder(
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return ListTile(
                          leading: Icon(Icons.event_seat),
                          title: Text(record.seatName),
                          subtitle: Text(
                            '开始: ${record.startTime.toString().substring(0, 16)}\n结束: ${record.endTime.toString().substring(0, 16)}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            tooltip: '取消预约',
                            onPressed: () => _cancelReservation(record),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class SeatDetailPage extends StatefulWidget {
  final Seat seat;

  const SeatDetailPage({required this.seat});

  @override
  _SeatDetailPageState createState() => _SeatDetailPageState();
}

class _SeatDetailPageState extends State<SeatDetailPage> {
  DateTime _selectedStartTime = DateTime.now();
  DateTime _selectedEndTime = DateTime.now().add(Duration(hours: 1));
  bool? _canReserve; // null: 未检测, true: 可预约, false: 冲突

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    setState(() {
      _canReserve = null; // 开始检测时设为null，显示加载
    });
    final seatName = widget.seat.name;
    final startTime = _selectedStartTime.toIso8601String();
    final endTime = _selectedEndTime.toIso8601String();
    try {
      final res = await http.get(
        Uri.http('10.0.2.2:8080', '/seats', {
          'floor': widget.seat.floor,
          'zone': widget.seat.zone,
          'start_time': startTime,
          'end_time': endTime,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final seats =
            (data['seats'] as List).map((e) => Seat.fromJson(e)).toList();
        final thisSeat = seats.firstWhere(
          (s) => s.name == seatName,
          orElse: () => widget.seat,
        );
        setState(() {
          _canReserve = thisSeat.isAvailable;
        });
      }
    } catch (e) {
      setState(() {
        _canReserve = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('座位详情')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_canReserve == null)
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('正在检测座位是否空闲...'),
                ],
              )
            else
              Chip(
                label: Text(_canReserve! ? '可用' : '已占用'),
                backgroundColor:
                    _canReserve! ? Colors.green[200] : Colors.red[200],
              ),
            SizedBox(height: 12),
            Text(
              '${widget.seat.zone}区 ${widget.seat.name}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text('${widget.seat.floor}楼'),
            SizedBox(height: 24),
            // 时间选择器
            ListTile(
              title: Text(
                '开始时间: ${_selectedStartTime.toString().substring(0, 16)}',
              ),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final picked = await showDateTimePicker(
                  context,
                  _selectedStartTime,
                );
                if (picked != null) {
                  setState(() => _selectedStartTime = picked);
                  _checkAvailability();
                }
              },
            ),
            ListTile(
              title: Text(
                '结束时间: ${_selectedEndTime.toString().substring(0, 16)}',
              ),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final picked = await showDateTimePicker(
                  context,
                  _selectedEndTime,
                );
                if (picked != null) {
                  setState(() => _selectedEndTime = picked);
                  _checkAvailability();
                }
              },
            ),
            SizedBox(height: 24),
            if (_canReserve == false)
              Text('该时间段已被预约', style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _canReserve == true ? _handleReservation : null,
              child: Text('立即预约'),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> showDateTimePicker(
    BuildContext context,
    DateTime initial,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 7)),
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _handleReservation() async {
    final username = globalUsername ?? '';
    final seatName = widget.seat.name;
    final startTime = _selectedStartTime.toIso8601String();
    final endTime = _selectedEndTime.toIso8601String();

    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请先登录')));
      return;
    }

    if (_selectedStartTime.isAfter(_selectedEndTime) ||
        _selectedStartTime.isAtSameMomentAs(_selectedEndTime)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('开始时间必须早于结束时间')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/reserve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'seat_name': seatName,
          'start_time': startTime,
          'end_time': endTime,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('预约成功！')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['msg'] ?? '预约失败')));
        // 预约失败后，刷新可用性
        _checkAvailability();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('无法连接服务器')));
    }
  }
}

void _goToDetail(BuildContext context, Seat seat) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SeatDetailPage(seat: seat)),
  );
}
