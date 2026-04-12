import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanakam_app/constants.dart';
import 'package:vanakam_app/services/api_service.dart';
import 'package:vanakam_app/services/auth_service.dart';

class AdminServerScreen extends StatefulWidget {
  const AdminServerScreen({super.key});

  @override
  State<AdminServerScreen> createState() => _AdminServerScreenState();
}

class _AdminServerScreenState extends State<AdminServerScreen> {
  bool _isStarting = false;
  bool _obscurePassword = true;
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '22');
  final TextEditingController _terminalInputController = TextEditingController();
  
  final List<String> _terminalOutput = [];
  final ScrollController _terminalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _hostController.addListener(() {
      final host = _hostController.text.trim();
      if (host.isNotEmpty) {
        // Automatically update the API base to match the SSH host for dev convenience
        ServerConfig.apiBase = 'http://$host:3000';
      }
    });

    _loadCredentials();
    _hostController.addListener(() {
      if (mounted) setState(() {});
    });
    _userController.addListener(() {
      if (mounted) setState(() {});
    });
    _portController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hostController.text = prefs.getString('ssh_host') ?? '';
      _userController.text = prefs.getString('ssh_user') ?? '';
      _passController.text = prefs.getString('ssh_pass') ?? '';
      _portController.text = prefs.getString('ssh_port') ?? '22';
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ssh_host', _hostController.text);
    await prefs.setString('ssh_user', _userController.text);
    await prefs.setString('ssh_pass', _passController.text);
    await prefs.setString('ssh_port', _portController.text);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SSH Configuration saved locally!', style: GoogleFonts.rajdhani()),
          backgroundColor: McColors.grass,
        ),
      );
    }
  }

  void _addTerminalLine(String line) {
    if (!mounted) return;
    setState(() {
      _terminalOutput.add(line);
      // Keep terminal history manageable
      if (_terminalOutput.length > 200) _terminalOutput.removeAt(0);
    });
    
    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_terminalScrollController.hasClients) {
        _terminalScrollController.animateTo(
          _terminalScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startServer() async {
    setState(() {
      _isStarting = true;
      _terminalOutput.clear();
    });
    
    final host = _hostController.text.trim();
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    _addTerminalLine('--- BOOT SEQUENCE INITIATED ---');
    _addTerminalLine('\$ ssh $user@$host');
    _addTerminalLine('Warning: Permanently added \'$host\' (RSA) to the list of known hosts.');
    _addTerminalLine('Connecting to $host...');

    try {
      final stream = ApiService().streamData('/api/start-server', {
        'sshHost': host,
        'sshUser': user,
        'sshPass': pass,
        'sshPort': _portController.text.trim(),
      });

      bool hasError = false;
      await for (final line in stream) {
        _addTerminalLine(line);
        if (line.contains('❌') || line.contains('Error') || line.contains('Failed')) {
          hasError = true;
        }
      }

      if (mounted) {
        setState(() => _isStarting = false);
        if (hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deployment failed. Check terminal for details.', style: GoogleFonts.rajdhani()),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Server process finished successfully.', style: GoogleFonts.rajdhani()),
              backgroundColor: McColors.grass,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isStarting = false);
        _addTerminalLine('❌ Application Error: $e');
      }
    }
  }

  Future<void> _stopServer() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Force stopping server...', style: GoogleFonts.rajdhani()),
        backgroundColor: Colors.redAccent,
      ),
    );
    final response = await ApiService().postData('/api/stop-server', {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.success ? 'Server stopped.' : 'Failed: ${response.message}', style: GoogleFonts.rajdhani()),
          backgroundColor: response.success ? McColors.grass : Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _sendTerminalCommand() async {
    final cmd = _terminalInputController.text.trim();
    if (cmd.isEmpty) return;

    _terminalInputController.clear();
    _addTerminalLine('\$ $cmd');

    final res = await ApiService().postData('/api/send-command', {
      'command': cmd,
      'sshHost': _hostController.text.trim(),
      'sshUser': _userController.text.trim(),
      'sshPass': _passController.text.trim(),
    });

    if (!res.success) {
      _addTerminalLine('❌ Command Error: ${res.message}');
    } else {
      _addTerminalLine('✔ ${res.data ?? 'Command sent'}');
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _userController.dispose();
    _passController.dispose();
    _portController.dispose();
    _terminalInputController.dispose();
    _terminalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          FadeInDown(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADMIN PANEL',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white38,
                      ),
                    ),
                    Text(
                      'Server Control',
                      style: GoogleFonts.rajdhani(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const FaIcon(FontAwesomeIcons.gear, color: Colors.white54, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Minecraft Server Main Status Card
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const FaIcon(FontAwesomeIcons.database, color: Colors.cyanAccent, size: 24),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Minecraft Server',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
                              ),
                              child: Text(
                                'SERVER',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyanAccent,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monitor and start the game server.',
                          style: GoogleFonts.rajdhani(
                            fontSize: 14,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Main Control Card (Start/Stop)
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.server, color: Colors.greenAccent, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        'Main Control',
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Control the startup of the Minecraft server. This process will run in the background using a secure environment on your host machine.',
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _isStarting ? null : _startServer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7BC043),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: _isStarting 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const FaIcon(FontAwesomeIcons.play, size: 14),
                          label: Text(
                            _isStarting ? 'STARTING...' : 'Start Server',
                            style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _stopServer,
                          icon: const FaIcon(FontAwesomeIcons.powerOff, color: Colors.redAccent, size: 18),
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Technical Details & SSH Config
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.code, color: Colors.cyanAccent, size: 16),
                      const SizedBox(width: 12),
                      Text(
                        'Technical Details',
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Configuration Inputs
                  _buildTechnicalBlock('SSH HOST', _hostController, FontAwesomeIcons.networkWired),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTechnicalBlock('USER', _userController, FontAwesomeIcons.user)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTechnicalBlock('PORT', _portController, FontAwesomeIcons.hashtag)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTechnicalBlock('PASSWORD', _passController, FontAwesomeIcons.key, isPassword: true),
                  
                  const SizedBox(height: 16),
                  
                  // Script Path Simulation
                  _buildInfoBox('SCRIPT PATH', '/home/${_userController.text.isEmpty ? 'pranish' : _userController.text}/VanakamSMP/web_start.sh'),
                  const SizedBox(height: 12),
                  _buildInfoBox('EXECUTION CONTEXT', 'The script runs via Node builtin child_process module, detaching into a hidden terminal session.'),
                  
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _saveCredentials,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.cyanAccent,
                        backgroundColor: Colors.cyanAccent.withOpacity(0.05),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.save, size: 16),
                      label: Text('SAVE CONFIGURATION', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Node.js System Bridge (Code Concept)
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.nodeJs, color: Color(0xFF68A063), size: 18),
                      const SizedBox(width: 12),
                      Text(
                        'System Bridge',
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF68A063).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCodeLine('1', 'const { Client } = require("ssh2");', color: const Color(0xFF68A063)),
                        _buildCodeLine('2', 'const conn = new Client();', color: Colors.cyanAccent),
                        _buildCodeLine('3', 'conn.on("ready", () => {', color: Colors.blueAccent),
                        _buildCodeLine('4', '  conn.exec("bash start.sh", (err, stream) => {', color: Colors.white70),
                        _buildCodeLine('5', '    stream.on("data", (data) => console.log(data));', color: Colors.white70),
                        _buildCodeLine('6', '  });', color: Colors.blueAccent),
                        _buildCodeLine('7', '}).connect(sshConfig);', color: Colors.cyanAccent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Integration via SSH2 Node.js library for real-time stream processing.',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: Colors.white24,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 5. Host Statistics (Compact Row)
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Node', 'ENGINE', Colors.cyanAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('100%', 'INTEGRATION', Colors.greenAccent),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Terminal Header
          Row(
            children: [
              Text(
                'TERMINAL OUTPUT',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Divider(color: Colors.white10)),
            ],
          ),
          const SizedBox(height: 12),

          // Terminal
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                // Terminal Header (Mac Style)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.terminal, color: Colors.white38, size: 12),
                      const SizedBox(width: 10),
                      Text(
                        'vanakam-smp-boot',
                        style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _buildDot(Colors.redAccent),
                          const SizedBox(width: 6),
                          _buildDot(Colors.orangeAccent),
                          const SizedBox(width: 6),
                          _buildDot(Colors.greenAccent),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _terminalOutput.isEmpty
                    ? Center(child: Text('Console idle...', style: GoogleFonts.firaCode(color: Colors.white10, fontSize: 13)))
                    : ListView.builder(
                        controller: _terminalScrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _terminalOutput.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              _terminalOutput[index],
                              style: GoogleFonts.firaCode(
                                color: _terminalOutput[index].contains('❌') || _terminalOutput[index].contains('failed')
                                    ? Colors.redAccent 
                                    : _terminalOutput[index].contains('✅') || _terminalOutput[index].contains('✔')
                                        ? const Color(0xFF7BC043)
                                        : _terminalOutput[index].startsWith('\$')
                                            ? Colors.cyanAccent
                                            : Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                  ),
                  child: Row(
                    children: [
                      Text('\$ ', style: GoogleFonts.firaCode(color: Colors.cyanAccent, fontSize: 14)),
                      Expanded(
                        child: TextField(
                          controller: _terminalInputController,
                          style: GoogleFonts.firaCode(color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: 'Execute command...',
                            hintStyle: TextStyle(color: Colors.white10),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendTerminalCommand(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTechnicalBlock(String label, TextEditingController controller, dynamic icon, {bool isPassword = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.rajdhani(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 1)),
          TextField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            style: GoogleFonts.firaCode(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              suffixIconConstraints: const BoxConstraints(maxHeight: 20),
              suffixIcon: isPassword ? GestureDetector(
                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                child: FaIcon(_obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye, size: 12, color: Colors.white24),
              ) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.rajdhani(fontSize: 9, color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.rajdhani(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.5),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeLine(String lineNum, String code, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              lineNum,
              style: GoogleFonts.firaCode(fontSize: 10, color: Colors.white10),
            ),
          ),
          Expanded(
            child: Text(
              code,
              style: GoogleFonts.firaCode(fontSize: 10, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.8), width: 1),
      ),
    );
  }
}
